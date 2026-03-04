use dagger_sdk::{Directory, Query};
use eyre::WrapErr;

use crate::containers::ruby_builder;

/// Syntax-check all Ruby source files.
pub async fn run(client: &Query, source: Directory) -> eyre::Result<String> {
    let output = ruby_builder(client, source)
        .with_exec(vec![
            "sh", "-c",
            "ruby -c lib/forge_sdk/*.rb lib/forge_sdk.rb && echo 'check: syntax ok'",
        ])
        .stdout()
        .await
        .wrap_err("check failed")?;

    Ok(output)
}
