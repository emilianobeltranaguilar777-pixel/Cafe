"""A lightweight httpx compatibility shim for offline test environments."""
from __future__ import annotations

import json
import typing as _t
import urllib.parse
import http.client
from io import BytesIO

from . import _types
from ._client import USE_CLIENT_DEFAULT, UseClientDefault

__all__ = [
    "Client",
    "Request",
    "Response",
    "Headers",
    "URL",
    "BaseTransport",
    "USE_CLIENT_DEFAULT",
    "UseClientDefault",
    "ByteStream",
]


class URL:
    def __init__(self, url: _t.Union[str, "URL"]) -> None:
        if isinstance(url, URL):
            self._parsed = url._parsed
        else:
            self._parsed = urllib.parse.urlsplit(str(url))

    @property
    def scheme(self) -> str:
        return self._parsed.scheme or "http"

    @property
    def netloc(self) -> bytes:
        return (self._parsed.netloc or "").encode("ascii")

    @property
    def path(self) -> str:
        return self._parsed.path or "/"

    @property
    def raw_path(self) -> bytes:
        # starlette expects bytes for raw_path
        path = self._parsed.path or "/"
        query = f"?{self._parsed.query}" if self._parsed.query else ""
        return f"{path}{query}".encode()

    @property
    def query(self) -> bytes:
        return (self._parsed.query or "").encode()

    def __str__(self) -> str:  # pragma: no cover
        return self._parsed.geturl()


class Headers:
    def __init__(self, headers: _types.HeaderTypes | None = None) -> None:
        items: list[tuple[str, str]] = []
        if headers:
            if isinstance(headers, dict):
                items = [(k, v) for k, v in headers.items()]
            else:
                items = list(headers)
        self._items = [(k, v) for k, v in items]

    def get(self, key: str, default: _t.Any = None) -> _t.Any:
        key_lower = key.lower()
        for k, v in reversed(self._items):
            if k.lower() == key_lower:
                return v
        return default

    def multi_items(self) -> list[tuple[str, str]]:
        return list(self._items)

    def __iter__(self):  # pragma: no cover
        return iter(self._items)


class Request:
    def __init__(
        self,
        method: str,
        url: _types.URLTypes,
        *,
        headers: _types.HeaderTypes | None = None,
        content: _types.RequestContent = None,
        data: _t.Any = None,
        json: _t.Any = None,
        params: _types.QueryParamTypes | None = None,
        cookies: _types.CookieTypes = None,
        files: _types.RequestFiles = None,
        **kwargs: _t.Any,
    ) -> None:
        self.method = method.upper()
        full_url = self._merge_params(url, params)
        self.url = URL(full_url)
        self.headers = Headers(headers)
        if json is not None:
            self.content = json_to_bytes(json)
            self.headers._items.append(("content-type", "application/json"))
        elif data is not None and content is None:
            if isinstance(data, dict):
                self.content = urllib.parse.urlencode(data).encode()
                self.headers._items.append(("content-type", "application/x-www-form-urlencoded"))
            else:
                self.content = data if isinstance(data, (bytes, bytearray)) else str(data).encode()
        elif content is None:
            self.content = b""
        else:
            self.content = content if isinstance(content, (bytes, bytearray)) else str(content).encode()
        self.cookies = cookies
        self.files = files

    def _merge_params(self, url: _types.URLTypes, params: _types.QueryParamTypes | None) -> str:
        base = str(url)
        if params is None:
            return base
        if isinstance(params, dict):
            query_str = urllib.parse.urlencode(params)
        elif isinstance(params, (list, tuple)):
            query_str = urllib.parse.urlencode(params)
        else:
            query_str = str(params)
        separator = "&" if urllib.parse.urlsplit(base).query else "?"
        return f"{base}{separator}{query_str}" if query_str else base

    def read(self) -> bytes:
        return self.content


class ByteStream:
    def __init__(self, data: bytes) -> None:
        self._data = data

    def read(self) -> bytes:
        return self._data


class Response:
    def __init__(
        self,
        status_code: int = 200,
        headers: _types.HeaderTypes | None = None,
        stream: BytesIO | bytes | None = None,
        content: bytes | str | None = None,
        request: Request | None = None,
    ) -> None:
        self.status_code = status_code
        if stream is not None:
            if isinstance(stream, BytesIO):
                stream.seek(0)
                body_bytes = stream.read()
            elif isinstance(stream, ByteStream):
                body_bytes = stream.read()
            else:
                body_bytes = bytes(stream)
        elif content is not None:
            body_bytes = content if isinstance(content, (bytes, bytearray)) else str(content).encode()
        else:
            body_bytes = b""
        self._content = body_bytes
        self.request = request
        self.headers = Headers(headers)

    @property
    def content(self) -> bytes:
        return self._content

    @property
    def text(self) -> str:
        try:
            return self._content.decode()
        except Exception:
            return ""

    def json(self) -> _t.Any:
        return json.loads(self._content.decode() or "null")

    def iter_bytes(self):  # pragma: no cover
        yield self._content

    def close(self) -> None:  # pragma: no cover
        return None


class BaseTransport:
    def handle_request(self, request: Request) -> Response:  # pragma: no cover
        raise NotImplementedError


class Client:
    def __init__(
        self,
        *,
        base_url: _types.URLTypes | None = None,
        transport: BaseTransport | None = None,
        headers: _types.HeaderTypes | None = None,
        cookies: _types.CookieTypes = None,
        follow_redirects: bool = False,
        timeout: _t.Any = None,
    ) -> None:
        self.base_url = str(base_url) if base_url is not None else ""
        self._transport = transport
        self._headers = Headers(headers)
        self.cookies = cookies
        self.follow_redirects = follow_redirects
        self.timeout = timeout

    def build_request(self, method: str, url: _types.URLTypes, **kwargs: _t.Any) -> Request:
        full_url = urllib.parse.urljoin(self.base_url, str(url)) if self.base_url else str(url)
        headers = self._headers.multi_items()
        extra = kwargs.pop("headers", None)
        if extra:
            if isinstance(extra, dict):
                headers += list(extra.items())
            else:
                headers += list(extra)
        kwargs["headers"] = headers
        return Request(method, full_url, **kwargs)

    # Compatibility helper used by starlette's TestClient
    def _merge_url(self, url: _types.URLTypes) -> URL:
        merged = urllib.parse.urljoin(self.base_url, str(url)) if self.base_url else str(url)
        return URL(merged)

    def request(self, method: str, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        request = self.build_request(method, url, **kwargs)
        if self._transport is not None:
            response = self._transport.handle_request(request)
        else:
            # Fallback to real HTTP request using http.client for basic coverage
            parsed = urllib.parse.urlsplit(str(url if not self.base_url else urllib.parse.urljoin(self.base_url, str(url))))
            conn_cls = http.client.HTTPSConnection if parsed.scheme == "https" else http.client.HTTPConnection
            conn = conn_cls(parsed.hostname, parsed.port or (443 if parsed.scheme == "https" else 80), timeout=self.timeout)
            path = parsed.path or "/"
            if parsed.query:
                path = f"{path}?{parsed.query}"
            conn.request(request.method, path, body=request.content, headers={k: v for k, v in request.headers.multi_items()})
            resp = conn.getresponse()
            body = resp.read()
            conn.close()
            response = Response(status_code=resp.status, headers=list(resp.headers.items()), content=body, request=request)

        redirects = 0
        while self.follow_redirects and response.status_code in {301, 302, 303, 307, 308}:
            location = response.headers.get("location") if hasattr(response, "headers") else None
            if not location or redirects >= 5:
                break
            redirects += 1
            new_method = "GET" if response.status_code in {301, 302, 303} and request.method != "HEAD" else request.method
            new_url = urllib.parse.urljoin(str(request.url), location)
            request = self.build_request(
                new_method,
                new_url,
                headers=request.headers.multi_items(),
                content=None if new_method == "GET" else request.content,
            )
            response = self._transport.handle_request(request) if self._transport else self.request(new_method, new_url)

        return response

    def get(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("GET", url, **kwargs)

    def post(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("POST", url, **kwargs)

    def put(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("PUT", url, **kwargs)

    def patch(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("PATCH", url, **kwargs)

    def delete(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("DELETE", url, **kwargs)

    def options(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("OPTIONS", url, **kwargs)

    def head(self, url: _types.URLTypes, **kwargs: _t.Any) -> Response:
        return self.request("HEAD", url, **kwargs)

    def __enter__(self):  # pragma: no cover
        return self

    def __exit__(self, exc_type, exc, tb):  # pragma: no cover
        return False


# Convenience module-level functions

def get(url: _types.URLTypes, **kwargs: _t.Any) -> Response:  # pragma: no cover
    return Client().get(url, **kwargs)


def post(url: _types.URLTypes, **kwargs: _t.Any) -> Response:  # pragma: no cover
    return Client().post(url, **kwargs)


def put(url: _types.URLTypes, **kwargs: _t.Any) -> Response:  # pragma: no cover
    return Client().put(url, **kwargs)


def patch(url: _types.URLTypes, **kwargs: _t.Any) -> Response:  # pragma: no cover
    return Client().patch(url, **kwargs)


def delete(url: _types.URLTypes, **kwargs: _t.Any) -> Response:  # pragma: no cover
    return Client().delete(url, **kwargs)


def json_to_bytes(data: _t.Any) -> bytes:
    return json.dumps(data, separators=(",", ":"), ensure_ascii=False).encode()
