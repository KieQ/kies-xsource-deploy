FROM node:latest AS front_builder

WORKDIR /root

RUN git clone https://github.com/KieQ/kies-xsource-frontend.git

WORKDIR /root/kies-xsource-frontend

RUN sh script/build.sh

FROM golang:latest AS back_builder

WORKDIR /root

RUN git clone https://github.com/KieQ/kies-xsource-backend.git

WORKDIR /root/kies-xsource-backend

RUN sh script/build.sh

FROM nginx:latest

COPY --from=front_builder /root/kies-xsource-frontend/dist/ /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

COPY default.conf.template /etc/nginx/conf.d/default.conf.template

COPY --from=back_builder /root/kies-xsource-backend/kies /root/

COPY --from=back_builder /root/kies-xsource-backend/script /root/script

WORKDIR /root/

CMD /bin/bash /root/script/run.sh& /bin/bash -c "envsubst '\$PORT:\$BACKEND_PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'