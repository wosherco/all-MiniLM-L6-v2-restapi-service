use axum::{
    extract::{Json, State},
    http::StatusCode,
    routing::{get, post},
    Router,
};
use rust_bert::pipelines::sentence_embeddings::{
    SentenceEmbeddingsBuilder, SentenceEmbeddingsModel,
};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, sync::Arc};
use tokio::sync::Mutex;
use tower_http::cors::{Any, CorsLayer};

#[derive(Debug, Deserialize)]
struct EmbeddingRequest {
    text: String,
}

#[derive(Debug, Serialize)]
struct EmbeddingResponse {
    embedding: Vec<f32>,
}

#[derive(Debug, Serialize)]
struct ErrorResponse {
    error: String,
}

#[derive(Debug, Serialize)]
struct HeartbeatResponse {
    status: String,
    version: String,
}

#[derive(Clone)]
struct AppState {
    model: Arc<Mutex<SentenceEmbeddingsModel>>,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize logging
    tracing_subscriber::fmt::init();

    // Initialize the model from local path
    let model = SentenceEmbeddingsBuilder::local(PathBuf::from("models/all-MiniLM-L6-v2"))
        .create_model()?;
    let model = Arc::new(Mutex::new(model));

    let state = AppState { model };

    // Configure CORS
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Build our application with routes
    let app = Router::new()
        .route("/embed", post(handle_embedding))
        .route("/health", get(handle_heartbeat))
        .with_state(state)
        .layer(cors);

    // Run it with hyper on localhost:3000
    tracing::info!("listening on {}", "0.0.0.0:3000");
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();

    Ok(())
}

async fn handle_embedding(
    State(state): State<AppState>,
    Json(payload): Json<EmbeddingRequest>,
) -> Result<Json<EmbeddingResponse>, (StatusCode, Json<ErrorResponse>)> {
    let model = state.model.lock().await;

    match model.encode(&[payload.text]) {
        Ok(embeddings) => {
            if let Some(embedding) = embeddings.first() {
                Ok(Json(EmbeddingResponse {
                    embedding: embedding.to_vec(),
                }))
            } else {
                Err((
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(ErrorResponse {
                        error: "No embedding generated".to_string(),
                    }),
                ))
            }
        }
        Err(e) => Err((
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ErrorResponse {
                error: e.to_string(),
            }),
        )),
    }
}

async fn handle_heartbeat() -> Json<HeartbeatResponse> {
    Json(HeartbeatResponse {
        status: "ok".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
    })
}
