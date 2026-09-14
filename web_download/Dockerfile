FROM nginx:alpine

# L'APK n'est pas copie : il est servi par GitHub Releases, et le .gitignore
# l'exclut du depot. Ce site ne sert que la page et le manifeste de version.
COPY web_download/index.html /usr/share/nginx/html/
COPY web_download/version.json /usr/share/nginx/html/

EXPOSE 80
