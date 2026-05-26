#!/usr/bin/env python3

import json as jsonlib
import typing as t
import urllib.request


def run(label, base_url):
    """Run all tests for a given base URL."""
    tests: list[dict[str, t.Any]] = [
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

    for test in tests:
        test_name = test["n"]
        path = test["u"]
        print(f"{label} ({test_name})... ", end="")

        try:
            with urllib.request.urlopen(base_url + path, timeout=5) as response:
                if header := test.get("h"):
                    assert header in response.headers.get("Cache-Control", "")
                elif text := test.get("t"):
                    resp = response.read().decode().strip()
                    assert resp == text, f"Expected '{text}', got '{resp}'"
                elif json := test.get("j"):
                    resp = jsonlib.loads(response.read().decode().strip())
                    for k, v in json.items():
                        assert resp.get(k) == v, (
                            f"Expected value '{v}' for key '{k}', got '{resp.get(k)}'"
                        )
            print("ok")
        except Exception as e:
            print(f"fail ({base_url + path}: {e})")


if __name__ == "__main__":
    run("nginx root", "http://localhost:4010")
    run("nginx subdir", "http://localhost:4011/gallery")
    run("lighttpd root", "http://localhost:4020")
    run("lighttpd subdir", "http://localhost:4021/gallery")
    run("varnish -> nginx root", "http://localhost:4030")
    run("apache root", "http://localhost:4040")
    run("apache subdir", "http://localhost:4041/gallery")
