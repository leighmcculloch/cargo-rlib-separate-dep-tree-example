use stellar_xdr::curr::ScSpecType;

pub fn sc_spec_type_variant_len() -> usize {
    ScSpecType::variants().len()
}
