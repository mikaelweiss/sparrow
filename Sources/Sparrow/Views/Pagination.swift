/// A pagination control for navigating paged content.
/// On mobile: simplified prev/next. On desktop: full page numbers.
public struct Pagination: PrimitiveView, Sendable {
    public let currentPage: Int
    public let totalPages: Int
    public let onPageChange: @Sendable (Int) -> Void

    public init(
        currentPage: Int,
        totalPages: Int,
        onPageChange: @escaping @Sendable (Int) -> Void = { _ in }
    ) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onPageChange = onPageChange
    }
}
