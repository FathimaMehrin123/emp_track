from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func

from backend.app.database.database import SessionLocal
from backend.app.models.user_model import User
from backend.app.models.attendance_model import Attendance
from backend.app.models.leave_model import LeaveRequest
from backend.app.utils.auth_util import get_current_user

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