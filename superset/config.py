"""Small production override loaded through SUPERSET_CONFIG_PATH.

Secrets are read from Docker secret files at runtime. They are intentionally
absent from the Dockerfile, image history, environment examples and Git.
"""

from __future__ import annotations

import os
from pathlib import Path


def read_secret(name: str) -> str:
    """Return a required Docker secret and fail fast when it is unavailable."""

    path = Path(os.environ.get(f"{name}_FILE", f"/run/secrets/{name}"))
    try:
        value = path.read_text(encoding="utf-8").strip()
    except OSError as exc:
        raise RuntimeError(f"Required secret {name} is unavailable at {path}") from exc
    if not value:
        raise RuntimeError(f"Required secret {name} is empty")
    return value


SECRET_KEY = read_secret("SUPERSET_SECRET_KEY")
SQLALCHEMY_DATABASE_URI = read_secret("SUPERSET_DATABASE_URI")
GUEST_TOKEN_JWT_SECRET = read_secret("SUPERSET_GUEST_TOKEN_JWT_SECRET")

# Trust exactly one reverse-proxy hop (Traefik) for the forwarded client,
# protocol, host and port values.
ENABLE_PROXY_FIX = True
PROXY_FIX_CONFIG = {
    "x_for": 1,
    "x_proto": 1,
    "x_host": 1,
    "x_port": 1,
    "x_prefix": 0,
}

SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "None"
WTF_CSRF_ENABLED = True

FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
}

# Cross-origin embedding is intentionally allowlisted. Provide one or more
# origins separated by spaces, for example "https://portal.example.com".
frame_ancestors = os.environ.get("SUPERSET_FRAME_ANCESTORS", "'self'").split()
TALISMAN_ENABLED = True
TALISMAN_CONFIG = {
    "content_security_policy": {
        "default-src": ["'self'"],
        "img-src": ["'self'", "blob:", "data:", "https:"],
        "worker-src": ["'self'", "blob:"],
        "connect-src": ["'self'", "https:"],
        "object-src": ["'none'"],
        "style-src": ["'self'", "'unsafe-inline'"],
        "script-src": ["'self'", "'strict-dynamic'"],
        "frame-ancestors": frame_ancestors,
    },
    "content_security_policy_nonce_in": ["script-src"],
    "force_https": True,
}
