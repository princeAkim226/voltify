FROM node:20-alpine

WORKDIR /app

COPY admin/ ./admin/
COPY netlify/functions/admin-api.js ./netlify/functions/admin-api.js
COPY admin-server/ ./admin-server/

ENV PORT=3000
EXPOSE 3000

USER node

CMD ["node", "admin-server/server.js"]
