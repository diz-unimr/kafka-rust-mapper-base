use crate::error::MappingError;

pub(crate) struct DummyMapper {}
impl DummyMapper {
    pub(crate) fn new() -> Result<Self, anyhow::Error> {
        Ok(DummyMapper {})
    }

    pub(crate) fn map(&self, payload: &String) -> Result<Option<String>, MappingError> {
        Ok(Some(format!("Mapped payload: {}", payload).to_string()))
    }
}
