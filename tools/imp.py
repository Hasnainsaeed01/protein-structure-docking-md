"""Minimal imp.find_module shim for running PyMOL on Python 3.12+ (imp was removed).
Only find_module is provided, matching what pymol/__init__.py needs.
"""
import importlib.util

def find_module(name, path=None):
    spec = importlib.util.find_spec(name, path)
    if spec is None:
        raise ImportError("No module named %r" % name)
    origin = spec.origin or ''
    if spec.submodule_search_locations is not None:
        return (None, origin, ('', '', 5))  # PKG_DIRECTORY
    if origin.endswith('.py'):
        return (open(origin), origin, ('.py', 'r', 1))  # PY_SOURCE
    return (None, origin, ('', '', 3))  # C_EXTENSION
