#!/usr/bin/env python3

import json as jsonlib
import urllib.request


def t(label, base_url):
    """Run all tests for a given base URL."""
    tests = [
        {"n": "niceurl", "u": "/nicetest", "t": "ok"},
        {"n": "uglyurl", "u": "/index.php?q=nicetest", "t": "ok"},
        {"n": "static files", "u": "/themes/default/style.css", "h": "max-age=86400"},
        {
            "n": "niceslash",
            "u": "/nicedebug/foo%2Fbar/1",
            "j": {"args": ["nicedebug", "foo%2Fbar", "1"]},
        },
        {
            "n": "niceslash",
            "u": "/nicedebug/foo%2Fbar/1",
            "j": {"args": ["nicedebug", "foo%2Fbar", "1"]},
        },
        {
            "n": "uglyslash",
            "u": "/index.php?q=nicedebug/foo%2Fbar/1",
            "j": {"args": ["nicedebug", "foo%2Fbar", "1"]},
        },
        {
            "n": "encoded",
            "u": "/index.php?q=nicedebug%2Fcake",
            "j": {"args": ["nicedebug", "cake"]},
        },
    ]

    for t in tests:
        test_name = t["n"]
        path = t["u"]
        print(f"{label} ({test_name})... ", end="")

        try:
            with urllib.request.urlopen(base_url + path, timeout=5) as response:
                if header := t.get("h"):
                    assert header in response.headers.get("Cache-Control", "")
                elif text := t.get("t"):
                    resp = response.read().decode().strip()
                    assert resp == text, f"Expected '{text}', got '{resp}'"
                elif json := t.get("j"):
                    resp = jsonlib.loads(response.read().decode().strip())
                    for k, v in json.items():
                        assert resp.get(k) == v, (
                            f"Expected value '{v}' for key '{k}', got '{resp.get(k)}'"
                        )
            print("ok")
        except Exception as e:
            print(f"fail ({base_url + path}: {e})")


if __name__ == "__main__":
    t("nginx root", "http://localhost:4010")
    t("nginx subdir", "http://localhost:4011/gallery")
    t("lighttpd root", "http://localhost:4020")
    t("lighttpd subdir", "http://localhost:4021/gallery")
    t("varnish -> nginx root", "http://localhost:4030")
    t("apache root", "http://localhost:4040")
    t("apache subdir", "http://localhost:4041/gallery")
