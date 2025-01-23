import reflex as rx

config = rx.Config(
    app_name="example_reflex",
    db_url="sqlite:///reflex.db",
    gunicorn_workers=1,
)
