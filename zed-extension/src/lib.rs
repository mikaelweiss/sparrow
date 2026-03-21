use zed_extension_api as zed;

struct SparrowPreviewExtension;

impl zed::Extension for SparrowPreviewExtension {
    fn new() -> Self {
        SparrowPreviewExtension
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        if language_server_id.as_ref() != "sparrow-preview" {
            return Err("Unknown language server".into());
        }

        // Only activate for Sparrow projects.
        // Check if Package.swift exists and contains a Sparrow dependency.
        let is_sparrow = worktree
            .read_text_file("Package.swift")
            .map(|content| {
                content.contains("sparrow") || content.contains("Sparrow")
            })
            .unwrap_or(false);

        if !is_sparrow {
            return Err("Not a Sparrow project".into());
        }

        // Resolve the sparrow binary from PATH
        let sparrow_path = worktree
            .which("sparrow")
            .ok_or("Could not find 'sparrow' on PATH. Run: swift package experimental-install")?;

        // Start the preview server as an LSP process.
        // Zed manages the lifecycle: starts on workspace open, kills on close.
        // The preview chrome is available at http://localhost:5457/_preview/
        Ok(zed::Command {
            command: sparrow_path,
            args: vec![
                "preview".to_string(),
                "--lsp".to_string(),
                "--no-browser".to_string(),
                "--port".to_string(),
                "5457".to_string(),
            ],
            env: Default::default(),
        })
    }
}

zed::register_extension!(SparrowPreviewExtension);
