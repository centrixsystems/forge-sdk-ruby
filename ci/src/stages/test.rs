use dagger_sdk::{Directory, Query};
use eyre::WrapErr;

use crate::containers::ruby_builder;

/// Run Ruby tests.
pub async fn run(client: &Query, source: Directory) -> eyre::Result<String> {
    let output = ruby_builder(client, source)
        .with_exec(vec!["ruby", "-Ilib", "test/test_client.rb"])
        .with_exec(vec!["sh", "-c", "echo 'test: all tests passed'"])
        .stdout()
        .await
        .wrap_err("test failed")?;

    Ok(output)
}
