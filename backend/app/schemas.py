from pydantic import BaseModel
from typing import Optional

class Event(BaseModel):
    id: Optional[int]
    ts: str
    src_ip: Optional[str]
    src_port: Optional[int]
    dest_port: Optional[int]
    protocol: Optional[str]
    payload_preview: Optional[str]
