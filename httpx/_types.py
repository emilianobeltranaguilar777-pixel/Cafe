import typing as _t

URLTypes = _t.Union[str, "URL"]
QueryParamTypes = _t.Union[dict, list, tuple, str, None]
HeaderTypes = _t.Union[dict[str, str], list[tuple[str, str]], tuple[tuple[str, str], ...]]
CookieTypes = _t.Union[dict[str, str], list[tuple[str, str]], tuple[tuple[str, str], ...], None]
AuthTypes = _t.Any
TimeoutTypes = _t.Any
RequestContent = _t.Union[str, bytes, bytearray, None]
RequestFiles = _t.Any
