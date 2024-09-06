#FROM registry.suse.com/bci/nodejs:20 as buildjs
#COPY . /usr/src
#WORKDIR /usr/src/ui
#RUN npm install
#WORKDIR /usr/src
#RUN cp -f ui/semantic.theme.config ui/semantic/src/theme.config && \
#    mkdir -p ui/semantic/src/themes/app && \
#    cp -rf ui/semantic.theme/* ui/semantic/src/themes/app
#WORKDIR /usr/src/ui/semantic
#RUN npx gulp build

FROM registry.suse.com/bci/golang:1.22 as buildgo
COPY . /go/src
WORKDIR /go/src
RUN go build

FROM registry.suse.com/bci/bci-minimal:15.5 as run
COPY ./static /static
COPY ./templates /templates
COPY --from=buildgo /go/src/cow-demo /bin/cow-demo
#COPY --from=buildjs /usr/src/app/ui/semantic/dist/semantic.min.css /static/dist/semantic.min.css
#COPY --from=buildjs /usr/src/app/ui/semantic/dist/semantic.min.js /static/dist/semantic.min.js
#COPY --from=buildjs /usr/src/app/ui/semantic/dist/themes/default/assets /static/dist/themes/default/
EXPOSE 8080
ENTRYPOINT ["/bin/cow-demo"]
