# Catalogue marketing Lumi-Dec

PDF de présentation commerciale : éclairage, aménagements intérieurs et enseignes.

## Contenu

- `Lumi-Dec_catalogue.pdf` — fichier à diffuser
- `images/1/` — éclairage (sections 1.A et 1.B)
- `images/2/` — spécialités & aménagements intérieurs
- `images/3/` — enseignes & signalétique lumineuse
- `generate_catalogue.py` — régénère le PDF depuis les images

## Régénérer

```bash
pip3 install reportlab pillow
python3 catalogue/generate_catalogue.py
```

Ajouter ou retirer des `.jpg` dans `images/{1,2,3}/` puis relancer le script.
