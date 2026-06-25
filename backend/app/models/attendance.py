from datetime import date, datetime, timezone
import uuid
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import UUID, Date, DateTime, ForeignKey, String

from backend.app.database.database import Base


class Attendance(Base):
    __tablename__ = "attendance"
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    attendance_date: Mapped[date] = mapped_column(Date, nullable=False)
# Get today's date using a common time standard (UTC).
    check_in_time: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False
    )

    # Present / Late
    status: Mapped[str] = mapped_column(String(20), nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )