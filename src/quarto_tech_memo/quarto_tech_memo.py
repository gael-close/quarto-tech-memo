import subprocess
from pathlib import Path
import os
import sys
import shutil
from contextlib import contextmanager
from enum import Enum
import typer

app = typer.Typer()


@contextmanager
def change_dir(destination):
    prev_dir = os.getcwd()
    os.chdir(destination)
    try:
        yield
    finally:
        os.chdir(prev_dir)


class Format(str, Enum):
    f1 = "memo1"
    f2 = "memo2"
    f3 = "poster"
    f4 = "slides-pdf"
    f5 = "slides-pptx"
    f6 = "ieee"
    f7 = "page"
    f8 = "reveal"


# ---------------------------------------------------------------------------
# Font detection (cross-platform)
# ---------------------------------------------------------------------------

def _installed_fonts() -> set[str]:
    """Return a set of font family names available on the system."""
    # macOS / Linux: fontconfig
    if shutil.which("fc-list"):
        r = subprocess.run(
            ["fc-list", "--format=%{family}\n"],
            capture_output=True, text=True
        )
        return {line.strip().split(",")[0].strip()
                for line in r.stdout.splitlines() if line.strip()}
    # Windows: PowerShell
    if sys.platform == "win32" and shutil.which("powershell"):
        ps = (
            "[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null;"
            "(New-Object System.Drawing.Text.InstalledFontCollection).Families.Name"
        )
        r = subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps],
            capture_output=True, text=True
        )
        return {line.strip() for line in r.stdout.splitlines() if line.strip()}
    return set()


def _run_checks() -> bool:
    """Print tool and font checks. Return True if all passed."""
    ok = True

    def result(label: str, found: bool, detail: str = "") -> None:
        nonlocal ok
        mark = "[OK]  " if found else "[MISS]"
        line = f"  {mark} {label}"
        if detail:
            line += f"  — {detail}"
        print(line)
        if not found:
            ok = False

    print("\n── Tools ─────────────────────────────────────────────────────")

    quarto_path = shutil.which("quarto")
    if quarto_path:
        r = subprocess.run(["quarto", "--version"], capture_output=True, text=True)
        result("quarto", True, f"v{r.stdout.strip()}  ({quarto_path})")
    else:
        result("quarto", False, "install via: uv tool install quarto-cli --with typst")

    typst_path = shutil.which("typst")
    if typst_path:
        r = subprocess.run(["typst", "--version"], capture_output=True, text=True)
        result("typst", True, f"{r.stdout.strip()}  ({typst_path})")
    else:
        r = subprocess.run(["quarto", "check"], capture_output=True, text=True) if quarto_path else None
        via_quarto = r and "Typst" in r.stdout
        result("typst (via quarto)", via_quarto,
               "bundled" if via_quarto else "install via: uv tool install quarto-cli --with typst")

    xelatex_path = shutil.which("xelatex")
    if xelatex_path:
        r = subprocess.run(["xelatex", "--version"], capture_output=True, text=True)
        ver = r.stdout.splitlines()[0] if r.stdout else "?"
        result("xelatex", True, f"{ver}  (needed for --to ieee)")
    else:
        result("xelatex", False,
               "optional — needed for --to ieee; install via: quarto install tinytex")

    print("\n── Fonts ─────────────────────────────────────────────────────")
    installed = _installed_fonts()
    if not installed:
        print("  [WARN] Cannot detect installed fonts on this platform.")
    else:
        font_checks = [
            ("Fira Sans",            "Typst: body / headings (fallback: Arial, Liberation Sans)"),
            ("Fira Math",            "Typst: math equations (fallback: New Computer Modern Math)"),
            ("Fira Code",            "Typst: code / monospace (fallback: DejaVu Sans Mono)"),
            ("TeX Gyre Termes",      "IEEE (XeLaTeX): body text"),
            ("TeX Gyre Termes Math", "IEEE (XeLaTeX): math — bundled with TinyTeX"),
        ]
        for name, note in font_checks:
            result(name, name in installed, note)

    print()
    if ok:
        print("All checks passed.")
    else:
        print("Some checks failed. See messages above.")
    return ok


# ---------------------------------------------------------------------------
# Main command
# ---------------------------------------------------------------------------

@app.command()
def tasks1(
    md_file: str = typer.Argument(None, help="Markdown note to convert"),
    to: Format = typer.Option("memo1", help="Output format"),
    preview: bool = typer.Option(False, help="Live preview mode"),
    check: bool = typer.Option(False, "--check", help="Check required tools and fonts, then exit"),
):
    if check:
        ok = _run_checks()
        raise typer.Exit(code=0 if ok else 1)

    if md_file is None:
        typer.echo("Error: missing argument MD_FILE.", err=True)
        raise typer.Exit(code=1)

    print(f"Converting markdown note {md_file} to format {to.value}")

    # Adjust format name for quarto
    if to.value == "ieee":
        fmt = "ieee-pdf"
    elif to.value == "page":
        fmt = "page-html"
    elif to.value == "reveal":
        fmt = "reveal-revealjs"
    elif to.value == "slides-pptx":
        fmt = "slides-pptx-pptx"
    else:
        fmt = to.value + "-typst"

    # Ensure the extension is installed
    src = Path(md_file)
    if not ((src.parent / "_extensions/gael-close/memo1").exists() or
            (src.parent / "_extensions/memo1").exists()):
        with change_dir(src.parent):
            print("Installing quarto-tech-memo extension")
            subprocess.run("quarto add gael-close/quarto-tech-memo --no-prompt --quiet", shell=True)

    # Render or preview
    if preview:
        subprocess.run(f'quarto preview "{md_file}" --to "{fmt}"', shell=True)
    else:
        subprocess.run(f'quarto render "{md_file}" --to "{fmt}"', shell=True)
        if to.value == "slides-pptx":
            _postprocess_pptx(src.with_suffix(".pptx"))


def _postprocess_pptx(pptx_file: Path) -> None:
    """Apply Slide subtitle (18pt), Deck metadata (18pt), and Fira Math in generated PPTX."""
    if not pptx_file.exists():
        return
    import zipfile
    import xml.etree.ElementTree as ET

    ns = {
        "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
        "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
        "mc": "http://schemas.openxmlformats.org/markup-compatibility/2006",
        "a14": "http://schemas.microsoft.com/office/drawing/2010/main",
        "m": "http://schemas.openxmlformats.org/officeDocument/2006/math",
    }
    for k, v in ns.items():
        ET.register_namespace(k, v)

    tmp_file = pptx_file.with_suffix(".tmp.pptx")
    with zipfile.ZipFile(pptx_file, "r") as zin, zipfile.ZipFile(tmp_file, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename.startswith("ppt/slides/slide") and item.filename.endswith(".xml"):
                root = ET.fromstring(data)
                modified = False
                for sp in root.findall(".//p:sp", ns):
                    ph = sp.find(".//p:nvPr/p:ph", ns)
                    if ph is None:
                        continue
                    ph_type = ph.get("type", "")
                    target_sz = "1800" if ph_type in ("title", "subTitle") else None
                    if not target_sz:
                        continue
                    for p in sp.findall(".//p:txBody/a:p", ns):
                        after_br = False
                        for child in p:
                            tag = child.tag.split("}")[-1]
                            if tag == "br":
                                after_br = True
                            elif tag == "r" and after_br:
                                rPr = child.find("a:rPr", ns)
                                if rPr is None:
                                    rPr = ET.Element(f"{{{ns['a']}}}rPr")
                                    child.insert(0, rPr)
                                rPr.set("sz", target_sz)
                                modified = True
                # Set Fira Math on all Office Math runs (<m:r>)
                for mr in root.findall(".//m:r", ns):
                    arPr = mr.find("a:rPr", ns)
                    if arPr is None:
                        arPr = ET.Element(f"{{{ns['a']}}}rPr")
                        for ftag in ("latin", "ea", "cs", "sym"):
                            ET.SubElement(arPr, f"{{{ns['a']}}}{ftag}", {"typeface": "Fira Math"})
                        # Insert before m:t
                        mt_idx = next((i for i, ch in enumerate(mr) if ch.tag.endswith("}t")), len(mr))
                        mr.insert(mt_idx, arPr)
                        modified = True
                if modified:
                    data = ET.tostring(root, encoding="utf-8", xml_declaration=True)
            zout.writestr(item, data)
    shutil.move(tmp_file, pptx_file)


def main():
    app()


if __name__ == "__main__":
    main()
