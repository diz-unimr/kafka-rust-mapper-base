use rdkafka::error::KafkaError;
use thiserror::Error;

#[derive(Debug, Error)]
pub(crate) enum ProcessingError {
    #[error("kafka error: {0}")]
    Kafka(#[from] KafkaError),
    #[error(transparent)]
    Mapping(#[from] MappingError),
}

#[derive(Debug, Error)]
pub(crate) enum MappingError {
    #[error(transparent)]
    Other(#[from] anyhow::Error),
}

impl MappingError {
    pub(crate) fn name(&self) -> &str {
        match self {
            MappingError::Other(_) => "Other",
        }
    }
}


