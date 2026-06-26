from datetime import datetime, timezone

from fastapi import APIRouter, Depends
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
        return {"error": "Only admin can access this route"}

    db = SessionLocal()

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

    db.close()

    return {
        "totalEmployees": total_employees,
        "presentToday": present_today,
        "lateToday": late_today,
        "pendingLeaves": pending_leaves
    }

@router.put("/leave/{leave_id}")

# Read the value from the URL path parameter and convert it into a Python UUID object.

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
        return {"error": "Only admin can access this route"}

    # Validate the status.
    if data.status not in ["Approved", "Rejected"]:
        return {
            "error": "Status must be either Approved or Rejected"
        }

    db = SessionLocal()

    # Find the leave request by its ID.
    leave_request = db.query(LeaveRequest).filter(
        LeaveRequest.id == leave_id
    ).first()

    if leave_request is None:
        db.close()
        return {"error": "Leave request not found"}

    # Update the leave status.
    leave_request.status = data.status

    # Save the admin's comment.
    leave_request.admin_comment = data.admin_comment

    db.commit()
    db.close()

    return {
        "message": f"Leave request {data.status.lower()} successfully"
    }


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
        return {"error": "Only admin can access this route"}

    db = SessionLocal()

    query = db.query(User).filter(
        User.role == "employee"
    )

    # Search by employee name or email.
    # or_() is a SQLAlchemy function that creates an SQL OR condition,Return rows where at least one of the conditions is true.
    
    if search:
        query = query.filter(
            or_(
                User.name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%")
            )
        )

    employees = query.order_by(User.name).all()

    db.close()

    return [
        {
            "id": str(employee.id),
            "name": employee.name,
            "email": employee.email,
            "role": employee.role
        }
        for employee in employees
    ]