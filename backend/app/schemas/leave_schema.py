from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel


class LeaveRequestData(BaseModel):
    leave_type: str
    start_date: date
    end_date: date
    reason: str


class LeaveResponse(BaseModel):
    id: UUID
    user_id: UUID
    leave_type: str
    start_date: date
    end_date: date
    reason: str
    status: str
    admin_comment: str | None
    created_at: datetime

    class Config:
        from_attributes = True