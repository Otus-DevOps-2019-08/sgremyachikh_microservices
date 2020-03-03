FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

# без gcc видел "unable to execute 'gcc': No such file or directory" при сборке.
# По этому поставлю, а потом удалю после requirements

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r /app/requirements.txt \
    && apk del --virtual .build-deps gcc musl-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]
