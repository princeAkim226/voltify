#!/usr/bin/env python3
"""Génère le catalogue marketing PDF Lumi-Dec.

Lit les images de catalogue/images/{1,2,3}/ et produit
catalogue/Lumi-Dec_catalogue.pdf.

    python3 catalogue/generate_catalogue.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image as PILImage
from reportlab.lib.colors import Color, HexColor, white, black
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas

ROOT = Path(__file__).resolve().parent
IMAGES = ROOT / "images"
OUT = ROOT / "Lumi-Dec_catalogue.pdf"

PAGE_W, PAGE_H = A4
MARGIN = 18 * mm

# Palette : nuit chaude + ambre (éclairage), pas de violet générique.
INK = HexColor("#1A1714")
MUTED = HexColor("#6B635A")
LINE = HexColor("#D9D2C8")
AMBER = HexColor("#C9953A")
CREAM = HexColor("#F7F3EC")
NIGHT = HexColor("#12100E")

pdfmetrics.registerFont(TTFont("Display", "/usr/share/fonts/truetype/noto/NotoSerifDisplay-Regular.ttf"))
pdfmetrics.registerFont(TTFont("DisplayBold", "/usr/share/fonts/truetype/noto/NotoSerifDisplay-Bold.ttf"))
pdfmetrics.registerFont(TTFont("Sans", "/usr/share/fonts/truetype/macos/PublicSans-Regular.ttf"))
pdfmetrics.registerFont(TTFont("SansBold", "/usr/share/fonts/truetype/macos/PublicSans-Bold.ttf"))


def list_images(section: str) -> list[Path]:
    folder = IMAGES / section
    return sorted(folder.glob("*.jpg")) + sorted(folder.glob("*.jpeg"))


def draw_footer(c: canvas.Canvas, page: int, total: int) -> None:
    y = 12 * mm
    c.setStrokeColor(LINE)
    c.setLineWidth(0.5)
    c.line(MARGIN, y + 5 * mm, PAGE_W - MARGIN, y + 5 * mm)
    c.setFillColor(MUTED)
    c.setFont("Sans", 7.5)
    c.drawString(MARGIN, y, "LUMI-DEC — CATALOGUE DÉCORATION & AMÉNAGEMENT SUR MESURE")
    c.drawRightString(PAGE_W - MARGIN, y, str(page))


def draw_wrapped(
    c: canvas.Canvas,
    text: str,
    x: float,
    y: float,
    max_width: float,
    font: str,
    size: float,
    leading: float,
    color: Color,
    align: str = "left",
) -> float:
    c.setFont(font, size)
    c.setFillColor(color)
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = f"{current} {word}".strip()
        if c.stringWidth(trial, font, size) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    for line in lines:
        if align == "center":
            c.drawCentredString(x + max_width / 2, y, line)
        else:
            c.drawString(x, y, line)
        y -= leading
    return y


def cover_page(c: canvas.Canvas, page: int, total: int) -> None:
    # Fond nuit plein format
    c.setFillColor(NIGHT)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)

    # Image d'ambiance en filigrane (pleine page, assombrie)
    cover_candidates = [
        IMAGES / "2" / "2_01.jpg",
        IMAGES / "1" / "1_10.jpg",
        IMAGES / "3" / "3_01.jpg",
    ]
    cover_img = next((p for p in cover_candidates if p.exists()), None)
    if cover_img:
        # Étire en cover, légèrement assombrie via un voile
        with PILImage.open(cover_img) as im:
            iw, ih = im.size
        scale = max(PAGE_W / iw, PAGE_H / ih)
        dw, dh = iw * scale, ih * scale
        x = (PAGE_W - dw) / 2
        y = (PAGE_H - dh) / 2
        c.saveState()
        c.setFillColor(NIGHT)
        c.drawImage(str(cover_img), x, y, width=dw, height=dh, preserveAspectRatio=True, mask="auto")
        c.setFillColor(Color(0.05, 0.04, 0.03, alpha=0.62))
        c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
        c.restoreState()

    # Accent ambre haut
    c.setFillColor(AMBER)
    c.rect(MARGIN, PAGE_H - 28 * mm, 28 * mm, 2.2 * mm, fill=1, stroke=0)

    c.setFillColor(white)
    c.setFont("Sans", 10)
    c.drawString(MARGIN, PAGE_H - 38 * mm, "CATALOGUE")

    c.setFont("DisplayBold", 54)
    c.drawString(MARGIN, PAGE_H - 62 * mm, "Lumi-Dec")

    c.setFillColor(AMBER)
    c.setFont("Sans", 9)
    c.drawString(MARGIN, PAGE_H - 72 * mm, "ÉCLAIRAGE  ·  AMÉNAGEMENT  ·  ENSEIGNES")

    y = draw_wrapped(
        c,
        "Spécialiste de la décoration des bâtiments, de la menuiserie sur mesure, "
        "des enseignes lumineuses et des solutions LED pour la finition des travaux.",
        MARGIN,
        PAGE_H - 92 * mm,
        PAGE_W - 2 * MARGIN,
        "Sans",
        11,
        16,
        Color(0.92, 0.90, 0.86),
    )

    c.setFillColor(Color(1, 1, 1, alpha=0.75))
    c.setFont("Sans", 9)
    c.drawString(MARGIN, 28 * mm, "DESIGN  •  FABRICATION  •  INSTALLATION  •  FINITION")

    c.setFillColor(MUTED)
    c.setFont("Sans", 8)
    c.drawRightString(PAGE_W - MARGIN, 14 * mm, str(page))


def section_intro(
    c: canvas.Canvas,
    page: int,
    total: int,
    number: str,
    title: str,
    subtitle: str,
    body: str,
) -> None:
    c.setFillColor(CREAM)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)

    c.setFillColor(AMBER)
    c.setFont("SansBold", 12)
    c.drawString(MARGIN, PAGE_H - 40 * mm, number)

    c.setFillColor(INK)
    c.setFont("DisplayBold", 28)
    y = PAGE_H - 56 * mm
    for line in title.split("\n"):
        c.drawString(MARGIN, y, line)
        y -= 34

    if subtitle:
        c.setFillColor(MUTED)
        c.setFont("SansBold", 10)
        c.drawString(MARGIN, y - 4 * mm, subtitle)
        y -= 14 * mm

    draw_wrapped(
        c,
        body,
        MARGIN,
        y - 4 * mm,
        PAGE_W - 2 * MARGIN,
        "Sans",
        11,
        16,
        INK,
    )
    draw_footer(c, page, total)


def gallery_pages(
    c: canvas.Canvas,
    start_page: int,
    total: int,
    images: list[Path],
    section_label: str,
    per_page: int = 2,
) -> int:
    """Dessine les pages galerie. Retourne le prochain numéro de page."""
    page = start_page
    content_top = PAGE_H - 28 * mm
    content_bottom = 22 * mm
    usable_h = content_top - content_bottom
    gap = 8 * mm
    usable_w = PAGE_W - 2 * MARGIN

    for i in range(0, len(images), per_page):
        batch = images[i : i + per_page]
        c.setFillColor(white)
        c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)

        c.setFillColor(MUTED)
        c.setFont("Sans", 8)
        c.drawString(MARGIN, PAGE_H - 16 * mm, section_label)

        n = len(batch)
        cell_h = (usable_h - gap * (n - 1)) / n
        y = content_top
        for img in batch:
            y -= cell_h
            # Cadre image avec letterbox crème
            c.setFillColor(CREAM)
            c.roundRect(MARGIN, y, usable_w, cell_h, 3, fill=1, stroke=0)
            # Image centrée, aspect ratio conservé
            with PILImage.open(img) as im:
                iw, ih = im.size
            pad = 4 * mm
            max_w = usable_w - 2 * pad
            max_h = cell_h - 2 * pad
            scale = min(max_w / iw, max_h / ih)
            dw, dh = iw * scale, ih * scale
            ix = MARGIN + (usable_w - dw) / 2
            iy = y + (cell_h - dh) / 2
            c.drawImage(str(img), ix, iy, width=dw, height=dh, preserveAspectRatio=True, mask="auto")
            y -= gap

        draw_footer(c, page, total)
        c.showPage()
        page += 1
    return page


def final_page(c: canvas.Canvas, page: int, total: int) -> None:
    """Conserve les textes de conclusion du catalogue d'origine."""
    c.setFillColor(white)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)

    c.setFillColor(AMBER)
    c.rect(PAGE_W / 2 - 14 * mm, PAGE_H - 36 * mm, 28 * mm, 2 * mm, fill=1, stroke=0)

    c.setFillColor(INK)
    c.setFont("DisplayBold", 22)
    c.drawCentredString(PAGE_W / 2, PAGE_H - 52 * mm, "UNE FINITION QUI FAIT LA")
    c.drawCentredString(PAGE_W / 2, PAGE_H - 62 * mm, "DIFFÉRENCE")

    y = draw_wrapped(
        c,
        "Du plafond à l'enseigne, nous créons des solutions cohérentes pour donner "
        "une identité forte à chaque espace. Chaque réalisation peut être adaptée "
        "aux dimensions, au style, aux matériaux et au budget du client.",
        MARGIN + 8 * mm,
        PAGE_H - 80 * mm,
        PAGE_W - 2 * MARGIN - 16 * mm,
        "Sans",
        10.5,
        15,
        MUTED,
        align="center",
    )

    y -= 10 * mm
    c.setFillColor(INK)
    c.setFont("SansBold", 11)
    c.drawString(MARGIN, y, "NOS PRINCIPAUX SAVOIR-FAIRE")
    y -= 10 * mm

    savoir_faire = [
        "Décoration intérieure et extérieure",
        "Plafonds décoratifs et éclairage intégré",
        "Menuiserie moderne et mobilier sur mesure",
        "Meubles TV et habillages muraux",
        "Enseignes lumineuses et lettres 3D",
        "Logos et signalétique personnalisés",
        "Rubans LED, profils LED et éclairage architectural",
        "Installation et finition sur chantier",
    ]
    c.setFont("Sans", 10)
    for item in savoir_faire:
        c.setFillColor(AMBER)
        c.circle(MARGIN + 2 * mm, y + 2.5, 1.6, fill=1, stroke=0)
        c.setFillColor(INK)
        c.drawString(MARGIN + 8 * mm, y, item)
        y -= 7.5 * mm

    c.setFillColor(MUTED)
    c.setFont("SansBold", 9)
    c.drawCentredString(PAGE_W / 2, 32 * mm, "SUR MESURE  •  MODERNE  •  PROFESSIONNEL")

    draw_footer(c, page, total)


def estimate_total_pages(img1: list[Path], img2: list[Path], img3: list[Path]) -> int:
    # couverture + intro1 + intros 1A/1B + galeries + intro2 + gal2 + intro3 + gal3 + finale
    def pages_for(n: int, per: int = 2) -> int:
        return (n + per - 1) // per if n else 0

    half = (len(img1) + 1) // 2
    return (
        1  # cover
        + 1  # section 1 intro
        + 1  # 1.A intro
        + pages_for(half)  # 1A gallery
        + 1  # 1.B intro
        + pages_for(len(img1) - half)  # 1B gallery
        + 1  # section 2 intro
        + pages_for(len(img2))
        + 1  # section 3 intro
        + pages_for(len(img3))
        + 1  # final
    )


def main() -> None:
    img1 = list_images("1")
    img2 = list_images("2")
    img3 = list_images("3")
    if not img1 or not img2 or not img3:
        raise SystemExit("Images manquantes dans catalogue/images/{1,2,3}/")

    # 1.A : première moitié (spots, strips, luminaires)
    # 1.B : seconde moitié (plafonds, rails magnétiques)
    mid = (len(img1) + 1) // 2
    img1a, img1b = img1[:mid], img1[mid:]

    total = estimate_total_pages(img1, img2, img3)
    c = canvas.Canvas(str(OUT), pagesize=A4)
    c.setTitle("Lumi-Dec — Catalogue décoration & aménagement sur mesure")
    c.setAuthor("Lumi-Dec")

    page = 1
    cover_page(c, page, total)
    c.showPage()
    page += 1

    section_intro(
        c,
        page,
        total,
        "POINT 1",
        "Éclairage",
        "1.A  Architectural & intérieur   ·   1.B  LED & décors de plafond",
        "Spots, strips LED, luminaires, plafonds lumineux et rails magnétiques "
        "pour mettre en valeur chaque volume — du salon à l'espace professionnel.",
    )
    c.showPage()
    page += 1

    # Sous-section 1.A
    c.setFillColor(white)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColor(AMBER)
    c.setFont("SansBold", 11)
    c.drawString(MARGIN, PAGE_H - 40 * mm, "1.A")
    c.setFillColor(INK)
    c.setFont("DisplayBold", 24)
    c.drawString(MARGIN, PAGE_H - 54 * mm, "Éclairage architectural")
    c.drawString(MARGIN, PAGE_H - 66 * mm, "& intérieur")
    draw_wrapped(
        c,
        "Spots, strips LED et luminaires pour un éclairage d'ambiance "
        "ou d'accentuation, intégré proprement au plafond et aux volumes.",
        MARGIN,
        PAGE_H - 82 * mm,
        PAGE_W - 2 * MARGIN,
        "Sans",
        11,
        16,
        MUTED,
    )
    draw_footer(c, page, total)
    c.showPage()
    page += 1

    page = gallery_pages(
        c, page, total, img1a, "1.A — ÉCLAIRAGE ARCHITECTURAL & INTÉRIEUR"
    )

    # Sous-section 1.B
    c.setFillColor(white)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColor(AMBER)
    c.setFont("SansBold", 11)
    c.drawString(MARGIN, PAGE_H - 40 * mm, "1.B")
    c.setFillColor(INK)
    c.setFont("DisplayBold", 24)
    c.drawString(MARGIN, PAGE_H - 54 * mm, "Éclairage LED")
    c.drawString(MARGIN, PAGE_H - 66 * mm, "& décors de plafond")
    draw_wrapped(
        c,
        "Plafonds lumineux, rails magnétiques et compositions géométriques "
        "pour une finition contemporaine et spectaculaire.",
        MARGIN,
        PAGE_H - 82 * mm,
        PAGE_W - 2 * MARGIN,
        "Sans",
        11,
        16,
        MUTED,
    )
    draw_footer(c, page, total)
    c.showPage()
    page += 1

    page = gallery_pages(
        c, page, total, img1b, "1.B — ÉCLAIRAGE LED & DÉCORS DE PLAFOND"
    )

    section_intro(
        c,
        page,
        total,
        "POINT 2",
        "Nos spécialités\n& aménagements\nintérieurs",
        "",
        "Meuble TV, meuble de cuisine sur-mesure, décoration murale en PVC ou "
        "bambou, rangements sur-mesure — des compositions adaptées aux "
        "dimensions et au style de chaque espace.",
    )
    c.showPage()
    page += 1

    page = gallery_pages(
        c, page, total, img2, "2 — NOS SPÉCIALITÉS & AMÉNAGEMENTS INTÉRIEURS"
    )

    section_intro(
        c,
        page,
        total,
        "POINT 3",
        "Enseignes\n& signalétique\nlumineuse",
        "",
        "Enseignes lumineuses 3D, caissons lumineux et panneaux publicitaires "
        "pour façades de boutiques et bureaux — fabrication et finition premium.",
    )
    c.showPage()
    page += 1

    page = gallery_pages(
        c, page, total, img3, "3 — ENSEIGNES & SIGNALÉTIQUE LUMINEUSE"
    )

    final_page(c, page, total)
    c.showPage()

    c.save()
    print(f"PDF écrit : {OUT} ({page} pages annoncées, total estimé {total})")


if __name__ == "__main__":
    main()
