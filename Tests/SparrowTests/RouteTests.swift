import Testing
@testable import Sparrow

@Suite("Route and Document Rendering")
struct RouteTests {

    @Test("Route stores path and title")
    func routeProperties() {
        let route = Route(path: "/about", title: "About Us", view: Text("About"))
        #expect(route.path == "/about")
        #expect(route.title == "About Us")
    }

    @Test("Route with nil title defaults to 'Sparrow App' in document")
    func routeDefaultTitle() {
        let route = Route(path: "/", title: nil, view: Text("Home"))
        let renderer = HTMLRenderer()
        let doc = route.renderDocument(with: renderer)
        #expect(doc.contains("<title>Sparrow App</title>"))
    }

    @Test("Route renders full HTML document structure")
    func routeDocumentStructure() {
        let route = Route(path: "/", title: "Test Page", view: Text("Content"))
        let renderer = HTMLRenderer()
        let doc = route.renderDocument(with: renderer)

        #expect(doc.contains("<!DOCTYPE html>"))
        #expect(doc.contains("<html lang=\"en\">"))
        #expect(doc.contains("<meta charset=\"utf-8\">"))
        #expect(doc.contains("<meta name=\"viewport\""))
        #expect(doc.contains("<title>Test Page</title>"))
        #expect(doc.contains("<style>"))
        #expect(doc.contains("<div id=\"sparrow-root\">"))
        #expect(doc.contains("Content"))
        #expect(doc.contains("</html>"))
    }

    @Test("Route title is HTML-escaped in document")
    func routeTitleEscaping() {
        let route = Route(path: "/", title: "Page <1> & \"2\"", view: Text("ok"))
        let renderer = HTMLRenderer()
        let doc = route.renderDocument(with: renderer)
        #expect(doc.contains("Page &lt;1&gt; &amp; &quot;2&quot;"))
    }

    @Test("Route document includes the default stylesheet")
    func routeIncludesCSS() {
        let route = Route(path: "/", title: nil, view: Text("ok"))
        let renderer = HTMLRenderer()
        let doc = route.renderDocument(with: renderer)
        #expect(doc.contains("--color-primary"))
        #expect(doc.contains("flex-col"))
    }

    // MARK: - Page convenience

    @Test("Page function creates a Route with the correct path and content")
    func pageConvenience() {
        let route = Page("/hello", title: "Hi") {
            Text("Hello!")
        }
        #expect(route.path == "/hello")
        #expect(route.title == "Hi")

        let renderer = HTMLRenderer()
        let doc = route.renderDocument(with: renderer)
        #expect(doc.contains("Hello!"))
    }

    // MARK: - RouteBuilder

    @Test("RouteBuilder collects multiple routes")
    func routeBuilder() {
        @RouteBuilder var routes: [Route] {
            Route(path: "/", title: nil, view: Text("Home"))
            Route(path: "/about", title: "About", view: Text("About"))
        }
        #expect(routes.count == 2)
        #expect(routes[0].path == "/")
        #expect(routes[1].path == "/about")
    }
}
