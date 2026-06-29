import uuid

from fastapi import APIRouter, Depends, HTTPException
from backend.app.database.database import SessionLocal
from backend.app.models.leave_model import LeaveRequest
from backend.app.schemas.leave_schema import LeaveRequestData
from backend.app.utils.auth_util import get_current_user

router = APIRouter(prefix="/leave", tags=["Leave"])


@router.post("/request")
def request_leave(
    data: LeaveRequestData,
    current_user=Depends(get_current_user)
):
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    if data.leave_type not in ["Sick", "Casual", "Emergency"]:
        raise HTTPException(status_code=400, detail="Invalid leave type")

    if data.reason.strip() == "":
        raise HTTPException(status_code=400, detail="Reason is required")

    if data.end_date < data.start_date:
        raise HTTPException(status_code=400, detail="End date cannot be before start date")

    db = SessionLocal()

    try:
        user_id = uuid.UUID(current_user["user_id"])

        new_leave = LeaveRequest(
            user_id=user_id,
            leave_type=data.leave_type,
            start_date=data.start_date,
            end_date=data.end_date,
            reason=data.reason,
            status="Pending"
        )

        db.add(new_leave)
        db.commit()

        return {
            "message": "Leave request submitted successfully",
            "status": "Pending"
        }

    except HTTPException:
        raise

    except Exception as e:
        db.rollback()
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while submitting leave request."
        )

    finally:
        db.close()


@router.get("/history")
def leave_history(current_user=Depends(get_current_user)):
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    db = SessionLocal()

    try:
        user_id = uuid.UUID(current_user["user_id"])

        leaves = db.query(LeaveRequest).filter(
            LeaveRequest.user_id == user_id
        ).order_by(
            LeaveRequest.created_at.desc()
        ).all()

        return [
            {
                "id": str(leave.id),
                "leave_type": leave.leave_type,
                "start_date": leave.start_date,
                "end_date": leave.end_date,
                "reason": leave.reason,
                "status": leave.status,
                "admin_comment": leave.admin_comment
            }
            for leave in leaves
        ]

    except HTTPException:
        raise

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while fetching leave history."
        )

    finally:
        db.close()