import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends

from backend.app.database.database import SessionLocal
from backend.app.models.attendance_model import Attendance
from backend.app.models.leave_model import LeaveRequest
from backend.app.utils.auth_util import get_current_user

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/stats")
def dashboard_stats(current_user=Depends(get_current_user)):
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    db = SessionLocal()

    user_id = uuid.UUID(current_user["user_id"])

    today = datetime.now(timezone.utc).date()

    # For now, working days means total days attendance was marked.
    working_days = db.query(Attendance).filter(
        Attendance.user_id == user_id
    ).count()

    present_days = db.query(Attendance).filter(
        Attendance.user_id == user_id,
        Attendance.status == "Present"
    ).count()

    late_days = db.query(Attendance).filter(
        Attendance.user_id == user_id,
        Attendance.status == "Late"
    ).count()

    # Simple absent calculation:
    # If working_days = present_days + late_days, absent_days will be 0.
    # Later you can calculate this using company calendar/month days.
    absent_days = working_days - (present_days + late_days)

    pending_leaves = db.query(LeaveRequest).filter(
        LeaveRequest.user_id == user_id,
        LeaveRequest.status == "Pending"
    ).count()

    approved_leaves = db.query(LeaveRequest).filter(
        LeaveRequest.user_id == user_id,
        LeaveRequest.status == "Approved"
    ).count()

    db.close()

    return {
        "workingDays": working_days,
        "presentDays": present_days,
        "lateDays": late_days,
        "absentDays": absent_days,
        "pendingLeaves": pending_leaves,
        "approvedLeaves": approved_leaves
    }