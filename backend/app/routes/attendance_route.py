import uuid
from datetime import datetime, timezone, time

from fastapi import APIRouter, Depends, HTTPException, status
from backend.app.database.database import SessionLocal
from backend.app.models.attendance_model import Attendance
from backend.app.utils.auth_util import get_current_user
from sqlalchemy import extract
router = APIRouter(prefix="/attendance", tags=["Attendance"])


@router.post("/checkin")
def check_in(current_user=Depends(get_current_user)):
    # isinstance(object, type) returns True if the object belongs to the specified type;
    # otherwise, it returns False.
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    db = SessionLocal()

    try:
        user_id = uuid.UUID(current_user["user_id"])

        today = datetime.now(timezone.utc).date()
        now = datetime.now(timezone.utc)

        existing_attendance = db.query(Attendance).filter(
            Attendance.user_id == user_id,
            Attendance.attendance_date == today
        ).first()

        if existing_attendance:
            raise HTTPException(
                status_code=400,
                detail="Attendance already marked today"
            )

        office_late_time = time(9, 15)

        if now.time() > office_late_time:
            attendance_status = "Late"
        else:
            attendance_status = "Present"

        new_attendance = Attendance(
            user_id=user_id,
            attendance_date=today,
            check_in_time=now,
            status=attendance_status
        )

        db.add(new_attendance)
        db.commit()

        return {
            "message": "Attendance marked successfully",
            "status": attendance_status
        }

    except HTTPException:
        raise

    except Exception as e:
        db.rollback()
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while checking in."
        )

    finally:
        db.close()


@router.get("/history")
def attendance_history(
    page: int = 1,
    month: int | None = None,
    year: int | None = None,
    current_user=Depends(get_current_user)
):
    if isinstance(current_user, dict) and "error" in current_user:
        return current_user

    db = SessionLocal()

    try:
        user_id = uuid.UUID(current_user["user_id"])

        query = db.query(Attendance).filter(
            Attendance.user_id == user_id
        )
        if month:
          query = query.filter(
            extract("month", Attendance.attendance_date) == month
         )

        if year:
          query = query.filter(
            extract("year", Attendance.attendance_date) == year
        )
        limit = 10
        # Skip the records from previous pages.
        offset = (page - 1) * limit

        records = query.order_by(
            Attendance.attendance_date.desc()
        ).offset(offset).limit(limit).all()

        return [
            {
                "id": str(record.id),
                "date": record.attendance_date,
                "check_in_time": record.check_in_time,
                "status": record.status
            }
            for record in records
        ]

    except HTTPException:
        raise

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=500,
            detail="Something went wrong while fetching attendance history."
        )

    finally:
        db.close()