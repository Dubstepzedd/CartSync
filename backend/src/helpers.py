from src.models import FriendRequest


def find_request(requests: list, *, sender_id: str = None, receiver_id: str = None) -> FriendRequest | None:
    return next(
        (r for r in requests if
         (sender_id is None or r.sender_id == sender_id) and
         (receiver_id is None or r.receiver_id == receiver_id)),
        None,
    )
