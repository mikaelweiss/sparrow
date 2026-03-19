import ArgumentParser
import SparrowCLICore

@main
struct SparrowCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sparrow",
        abstract: "Sparrow — a batteries-included Swift web framework",
        discussion: "Tip: You can also use `kln` as a shortcut for this command.",
        subcommands: [Run.self, Build.self, New.self],
        defaultSubcommand: Run.self
    )
}
