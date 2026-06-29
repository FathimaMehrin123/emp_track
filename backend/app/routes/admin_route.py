from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from uuid import UUID

from backend.app.database.database import SessionLocal
from backend.app.models.user_model import User
from backend.app.models.attendance_model import Attendance
from backend.app.models.leave_model import LeaveRequest
from backend.app.schemas.leave_schema import LeaveApprovalData
from backend.app.utils.auth_util import get_current_user
from sqlalchemy import or_

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/dashboard")
def admin_dashboard(current_user=Depends(get_current_user)):
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can access this route")

    db = SessionLocal()

    try:
        today = datetime.now(timezone.utc).date()

        total_employees = db.query(User).filter(
            User.role == "employee"
        ).count()

        present_today = db.query(Attendance).filter(
            Attendance.attendance_date == today,
            Attendance.status == "Present"
        ).count()

        late_today = db.query(Attendance).filter(
            Attendance.attendance_date == today,
            Attendance.status == "Late"
        ).count()

        pending_leaves = db.query(LeaveRequest).filter(
            LeaveRequest.status == "Pending"
        ).count()

        return {
            "totalEmployees": total_employees,
            "presentToday": present_today,
            "lateToday": late_today,
            "pendingLeaves": pending_leaves
        }

    except HTTPException:
        raise

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while fetching admin dashboard stats."
        )

    finally:
        db.close()

@router.put("/leave/{leave_id}")
def update_leave_status(
    leave_id: UUID,
    data: LeaveApprovalData,
    current_user=Depends(get_current_user)
):
    # Check whether the JWT token is valid.
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    # Allow only admins to approve or reject leave requests.
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can access this route")

    # Validate the status.
    if data.status not in ["Approved", "Rejected"]:
        raise HTTPException(status_code=400, detail="Status must be either Approved or Rejected")

    db = SessionLocal()

    try:
        # Find the leave request by its ID.
        leave_request = db.query(LeaveRequest).filter(
            LeaveRequest.id == leave_id
        ).first()

        if leave_request is None:
            raise HTTPException(status_code=404, detail="Leave request not found")

        # Update the leave status.
        leave_request.status = data.status

        # Save the admin's comment.
        leave_request.admin_comment = data.admin_comment

        db.commit()

        return {
            "message": f"Leave request {data.status.lower()} successfully"
        }

    except HTTPException:
        raise

    except Exception as e:
        db.rollback()
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while updating leave status."
        )

    finally:
        db.close()


@router.get("/employees")
def employee_list(
    search: str | None = None,
    current_user=Depends(get_current_user)
):
    # Validate JWT.
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    # Only admin can access.
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can access this route")

    db = SessionLocal()

    try:
        query = db.query(User).filter(
            User.role == "employee"
        )

        # Search by employee name or email.
        if search:
            query = query.filter(
                or_(
                    User.name.ilike(f"%{search}%"),
                    User.email.ilike(f"%{search}%")
                )
            )

        employees = query.order_by(User.name).all()

        return [
            {
                "id": str(employee.id),
                "name": employee.name,
                "email": employee.email,
                "role": employee.role
            }
            for employee in employees
        ]

    except HTTPException:
        raise

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while fetching employee list."
        )

    finally:
        db.close()


@router.get("/leaves")
def get_all_leave_requests(current_user=Depends(get_current_user)):
    # Validate JWT token.
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    # Allow only admins.
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can access this route")

    db = SessionLocal()

    try:
        # Get every leave request along with the employee details.
        leave_requests = (
            db.query(LeaveRequest, User)
            .join(User, LeaveRequest.user_id == User.id)
            .order_by(LeaveRequest.created_at.desc())
            .all()
        )

        return [
            {
                "id": str(leave.id),
                "employee_id": str(user.id),
                "employee_name": user.name,
                "employee_email": user.email,
                "leave_type": leave.leave_type,
                "start_date": leave.start_date,
                "end_date": leave.end_date,
                "reason": leave.reason,
                "status": leave.status,
                "admin_comment": leave.admin_comment,
                "created_at": leave.created_at,
            }
            for leave, user in leave_requests
        ]

    except HTTPException:
        raise

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while fetching all leave requests."
        )

    finally:
        db.close()