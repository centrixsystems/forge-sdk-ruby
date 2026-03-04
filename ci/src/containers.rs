use dagger_sdk::{Container, Directory, Query};

/// Base Ruby container with gem cache.
pub fn ruby_builder(client: &Query, source: Directory) -> Container {
    let gem_cache = client.cache_volume("forge-sdk-ruby-gems");

    client
        .container()
        .from("ruby:3.3-slim")
        .with_mounted_directory("/build", source)
        .with_workdir("/build")
        .with_mounted_cache("/usr/local/bundle", gem_cache)
}
