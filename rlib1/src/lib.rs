use stellar_xdr::curr::ScSpecType;

pub fn str() -> Vec<String> {
    ScSpecType::variants()
        .iter()
        .map(|v| v.name().to_string())
        .collect()
}
