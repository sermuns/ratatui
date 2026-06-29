# reusable rust image with `cargo-chef` installed
FROM rust:1.95-alpine3.23 AS chef
WORKDIR /work
RUN apk add --no-cache musl-dev cargo-chef

# prepare stage
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# build stage
FROM chef AS builder

# these layers should be cached by Docker
COPY --from=planner /work/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# only this may differ
COPY . .
RUN cargo build --release


# output stage
FROM rust:1.95-alpine3.23

COPY --from=builder /app/target/release/ironfoil /bin/ironfoil

WORKDIR /app
USER 1000:1000

ENTRYPOINT ["ironfoil"]


