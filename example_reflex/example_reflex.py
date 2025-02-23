"""Welcome to Reflex! This file outlines the steps to create a basic app."""

from typing import Any
import reflex as rx
from sqlmodel import select


class ExampleModel(rx.Model, table=True):
    a: int = 0
    b: str


class State(rx.State):
    """The app state."""

    value: int = 0

    models: list[ExampleModel] = []

    @rx.event
    def increment(self):
        self.value += 1

    @rx.event
    async def save_new_model(self, data: dict[str, Any]):
        model = ExampleModel(**data)
        print(model.dict())

        with rx.session() as session:
            session.add(model)
            session.commit()

        return rx.toast.info("Model saved!", position="top-center")

    @rx.event
    def show_models(self):
        with rx.session() as session:
            self.models = list(session.scalars(select(ExampleModel)))

        return rx.toast.info("Models loaded!")


def render_add_model() -> rx.Component:
    return rx.hstack(
        rx.form(
            rx.hstack(
                "enter a number",
                rx.input(name="a", label="A", type="number"),
            ),
            rx.hstack(
                "enter text",
                rx.input(name="b", label="B"),
            ),
            rx.button("Add Model"),
            on_submit=State.save_new_model,
        )
    )


def render_models() -> rx.Component:
    return rx.scroll_area(
        rx.vstack(
            rx.heading("Models", size="6"),
            rx.button("Show Models", on_click=State.show_models),
            rx.divider(),
            rx.vstack(
                rx.foreach(
                    State.models,
                    lambda model: rx.text(f"{model.a} - {model.b}"),
                ),
            ),
            spacing="5",
        ),
    )


def index() -> rx.Component:
    # Welcome Page (Index)
    return rx.container(
        rx.color_mode.button(position="top-right"),
        rx.vstack(
            rx.heading("This is just a temporary test app.", size="9"),
            rx.link(
                rx.button("Check out my portfolio"),
                href="https://adventuresoftim.com",
                is_external=True,
            ),
            rx.hstack(
                rx.button("Click me", on_click=State.increment),
                rx.text(f"Counter value: {State.value}"),
            ),
            rx.divider(),
            rx.vstack(
                render_add_model(),
                render_models(),
            ),
            spacing="5",
            justify="center",
            min_height="85vh",
        ),
        rx.logo(),
    )


app = rx.App()
app.add_page(index)
