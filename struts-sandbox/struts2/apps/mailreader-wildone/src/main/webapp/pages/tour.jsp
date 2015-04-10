<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=us-ascii"/>
    <link rel="stylesheet" type="text/css" href="../css/mailreader.css"/>

    <title>A Walking Tour of the Struts 2 MailReader Application</title>
</head>

<body>
<blockquote>
<h2>A Walking Tour of the Struts 2 MailReader Application</h2>

<p>
    <i>
        This article is meant to introduce a new user to Apache Struts 2 by
        "walking through" a simple, but functional, application.
        The article includes code snippets, but for the best result, you might
        want to install the MailReader application on your own development
        workstation and follow along.
        Of course, the full source code to the MailReader is included in the
        distribution.
    </i>

</p>

<p>
    <i>
        The tour assumes the reader has a basic understanding of the Java
        language, JavaBeans, web applications, and JavaServer Pages. For
        background on these technologies, see the
        <a href="http://struts.apache.org/primer.html">
            Key Technologies Primer</a>.
    </i>
</p>

<hr/>

<p>Logging In</p>

<ul>
    <li>
        <a href="#Welcome">Welcome</a>

        <ul>
            <li><a href="#web.xml">web.xml and resources.properties</a></li>

            <li><a href="#Welcome.do">Welcome.do</a></li>

            <li><a href="#Welcome.java">Welcome Action</a></li>

            <li><a href="#global-results">Global Results</a></li>

            <li><a href="#ApplicationListener.java">ApplicationListener.java</a></li>

            <li><a href="#resources.properties">Message Resources</a></li>

            <li><a href="#Welcome.jsp">Welcome Page</a></li>

        </ul>
    </li>
</ul>

<ul>
    <li>
        <a href="#Logon">Logon</a>
        <ul>

            <li><a href="#Logon.jsp">Logon Page</a></li>

            <li><a href="#Logon-validation.xml">Logon-validation.xml</a></li>

            <li><a href="#Logon.java">Logon.java</a></li>

            <li><a href="#MailreaderSupport.java">MailreaderSupport.java</a></li>

            <li><a href="#Logon.xml">Logon Configuration</a></li>

        </ul>
    </li>
</ul>

<ul>
    <li>
        <a href="#MainMenu">MainMenu</a>
    </li>
</ul>

<ul>
    <li>
        <a href="#Registration.jsp">Registration page</a>
        <ul>
            <li><a href="#iterator">iterator</a></li>
        </ul>
    </li>
</ul>

<ul>
    <li>
        <a href="#Subscription">Subscription</a>

        <ul>
            <li><a href="#SubscriptionAction.java">Subscription.java</a>
            </li>
        </ul>
    </li>
</ul>
<hr/>

<p>
    The premise of the MailReader is that it is the first iteration of a
    portal application.
    This version allows users to register and maintain a set of
    accounts with various mail servers.
    If completed, the application would let users read mail from their
    accounts.
</p>

<p>
    The MailReader application demonstrates registering with an application,
    logging into an application, maintaining a master record, and maintaining
    child records.
    This article overviews the constructs needed to do these things,
    including the server pages, Java classes, and configuration elements.
</p>

<p>
    For more about the MailReader, including alternate implementations and a
    set of formal Use Cases,
    please visit the <a href="http://www.StrutsUniversity.org/MailReader">
    Struts University MailReader site</a>.
</p>

<hr/>
<blockquote>
    <p><font class="hint">
        <strong>JAAS</strong> -
        Note that for compatibility and ease of deployment, the MailReader
        uses "application-based" authorization.
        However, use of the standard Java Authentication and Authorization
        Service (JAAS) is recommended for most applications.
        (See the <a
            href="http://struts.apache.org/primer.html">
        Key Technologies Primer</a> for more about
        authentication technologies.)
    </font></p>
</blockquote>
<hr/>

<p>
    The tour starts with how the initial welcome page is displayed, and
    then steps through logging into the application and editing a subscription.
    Please note that this not a quick peek at a "Hello World" application.
    The tour is a rich trek into a realistic, best practices application.
    You may need to adjust your chair and get a fresh cup of coffee.
    Printed, the article is 29 pages long (US).
</p>

<h3><a name="Welcome" id="Welcome">Welcome Page</a></h3>

<p>
    A web application, like any other web site, can specify a list of welcome pages.
    When you open a web application without specifying a particular page, a
    default "welcome page" is served as the response.
</p>

<h4><a name="web.xml" id="web.xml">web.xml</a></h4>

<p>
    When a web application loads,
    the container reads and parses the "Web Application Deployment
    Descriptor", or "web.xml" file.
    The framework plugs into a web application via a servlet filter.
    Like any filter, the "struts2" filter is deployed via the "web.xml".
</p>

<hr/>
<h5>web.xml - The Web Application Deployment Descriptor</h5>
<pre><code>&lt;?xml version="1.0" encoding="ISO-8859-1"?>
    &lt;!DOCTYPE web-app PUBLIC "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
    "http://java.sun.com/dtd/web-app_2_3.dtd">
    &lt;web-app>

    &lt;display-name>Struts 2 MailReader&lt;/display-name>

    <strong>&lt;filter>
        &lt;filter-name>struts2&lt;/filter-name>
        &lt;filter-class>
        org.apache.struts2.dispatcher.FilterDispatcher
        &lt;/filter-class>
        &lt;/filter></strong>

    &lt;filter-mapping>
    &lt;filter-name><strong>struts2</strong>&lt;/filter-name>
    &lt;url-pattern>/*&lt;/url-pattern>
    &lt;/filter-mapping>

    &lt;listener>
    &lt;listener-class>
    org.springframework.web.context.ContextLoaderListener
    &lt;/listener-class>
    &lt;/listener>

    &lt;!-- Application Listener for MailReader database -->
    &lt;listener>
    &lt;listener-class>
    mailreader2.ApplicationListener
    &lt;/listener-class>
    &lt;/listener>

    &lt;welcome-file-list>
    &lt;welcome-file>index.html&lt;/welcome-file>
    &lt;/welcome-file-list>

    &lt;/web-app></code></pre>
<hr/>

<p>
    Among other things,
    the web.xml specifies the "Welcome File List" for an application.
    When a web address refers to a directory rather than an individual file,
    the container consults the Welcome File List for the name of a page to
    open by default.
</p>

<p>
    However, most Struts applications do not refer to physical pages,
    but to "virtual resources" called <i>actions</i>.
    Actions specify code that we want to be run before a page
    or other resource renders the response.
    An accepted practice is to never link directly to server pages,
    but only to logical action mappings.
    By linking to actions, developers can often "rewire" an application
    without editing the server pages.
</p>

<hr/>
<h5>Best Practice:</h5>
<blockquote>
    <p><font class="hint">"Link actions not pages."</font></p>
</blockquote>
<hr/>

<p>
    The actions are listed in one or more XML configuration files,
    the default configuration file being named "struts.xml".
    When the application loads, the struts.xml, and any other files
    it includes, are parsed, and the framework creates a set of
    configuration objects.
    Among other things, the configuration maps a request for a certain
    page to a certain action mapping.
</p>

<p>
    Sites can list zero or more "Welcome" pages in the web.xml.
    Unless you are using Java 1.5, actions cannot be specified as a Welcome
    page.
    So, in the case of a Welcome page,
    how do we follow the best practice of navigating through actions
    rather than pages?
</p>

<p>
    One solution is to use a page to "bootstrap" one of our actions.
    We can register the usual "index.html" as the Welcome page and have it
    redirect to a "Welcome" action.
</p>

<hr/>
<h5>MailReader's index.html</h5>
<pre><code>&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
    &lt;html>&lt;head>
    &lt;META HTTP-EQUIV="Refresh" CONTENT="0;<strong>URL=Welcome.do</strong>">
    &lt;/head>
    &lt;body>
    &lt;p>Loading ...&lt;/p>
    &lt;/body>&lt;/html></code></pre>
<hr/>

<p>
    As an alternative,
    we could also have used a JSP page that issued the redirect with a Struts tag,
    but a plain HTML solution works as well.
</p>

<h4><a name="Welcome.do" id="Welcome.do">Welcome.do</a></h4>

<p>
    When the client requests "Welcome.do", the request is passed to the "struts2" FilterDispatcher
    (that we registered in the web.xml file).
    The FilterDispatcher retrieves the appropriate action mapping from the
    configuration.
    If we just wanted to forward to the Welcome page, we could use a simple
    configuration element.
</p>
<hr/>
<h5>A simple "forward thru" action element</h5>
<pre><code>&lt;action name="<strong>Welcome</strong>">
    &lt;result><strong>/pages/Welcome.jsp</strong>&lt;/result>
    &lt;/action></code></pre>
<hr/>

<p>
    If a client asks for the Welcome action ("Welcome.do), the "/page/Welcome.jsp"
    page would be returned in response.
    The client does not know, or need to know, that the physical resource is located at
    "/pages/Welcome.jsp".
    All the client knows is that it requested the resource "Welcome.do".
</p>

<p>
    But if we peek at the configuration file for the MailReader,
    we find a slightly more complicated XML element for the Welcome action.
</p>

<hr/>
<h5>The Welcome action element</h5>
<pre><code>&lt;action name="Welcome" <b>class="mailreader2.Welcome"</b>>
    &lt;result>/pages/Welcome.jsp&lt;/result>
    <strong>&lt;interceptor-ref name="guest"/></strong>
    &lt;/action></code></pre>
<hr/>

<p>
    Here, the <strong>Welcome</strong> Java class executes whenever
    someone asks for the Welcome action.
    As it completes, the Action class can select which "result" is displayed.
    The default result name is "success".
    Another available result, defined at a global scope, is "error".
</p>

<hr/>
<h5>Key concept:</h5>
<blockquote>
    <p>
        The Action class doesn't need to know what result type is needed
        for "success" or "error".
        The Action can just return the logical name for a result,
        without knowing how the result is implemented.
    </p>
</blockquote>
<hr/>

<p>
    The net effect is that all of the result details,
    including the paths to server pages,
    all can be declared <em>once</em> in the configuration.
    Tightly coupled implementation details are not scattered all over
    the application.
</p>

<hr/>
<h5>Key concept:</h5>
<blockquote>
    <p>
        The Struts configuration lets us separate concerns and "say it once".
        The configuration helps us "normalize" an application,
        in much the same way we normalize a database schema.
    </p>
</blockquote>
<hr/>


<p>
    OK ... but why would a Welcome Action want to choose between "success" and
    "error"?
</p>

<h4><a name="Welcome.java" id="Welcome.java">Welcome Action</a></h4>

<p>
    The MailReader application retains a list of users along with their email
    accounts.
    The application stores this information in a database.
    If the application can't connect to the database, the application can't do
    its job.
    So before displaying the Welcome <strong>page</strong>, the Welcome
    <strong>class</strong> checks to see if the database is available.
</p>

<p>
    The MailReader is also an internationalized application.
    So, the Welcome Action class checks to see if the message resources are
    available too.
    If both resources are available, the class passes back the "success" token.
    Otherwise, the class passes back the "error" token,
    so that the appropriate messages can be displayed.
</p>

<hr/>
<h5>The Welcome Action class</h5>
<pre><code>package mailreader2;
    public class Welcome extends MailreaderSupport {

    public String execute() {

    // Confirm message resources loaded
    String message = getText(Constants.ERROR_DATABASE_MISSING);
    if (Constants.ERROR_DATABASE_MISSING.equals(message)) {
    <strong>addActionError(Constants.ERROR_MESSAGES_NOT_LOADED);</strong>
    }

    // Confirm database loaded
    if (null==getDatabase()) {
    <strong>addActionError(Constants.ERROR_DATABASE_NOT_LOADED);</strong>
    }

    if (hasErrors()) {
    <strong>return ERROR;</strong>
    }
    else {
    <strong>return SUCCESS;</strong>
    }
    }
    }</code></pre>
<hr/>

<p>
    Several common result names are predefined,
    including ERROR, SUCCESS, LOGIN, NONE, and INPUT,
    so that these tokens can be used consistently across Struts 2 applications.
</p>


<h4><a name="global-results" id="global-results">Global Results</a></h4>

<p>
    As mentioned, "error" is defined in a global scope.
    Other actions may have trouble connecting to the database later,
    or other unexpected errors may occur.
    The MailReader defines the "error" result as a Global Result,
    so that any action can use it.
</p>

<hr/>
<h5>MailReader's global-result element</h5>
<pre><code> &lt;global-results>
    &lt;result name=<strong>"error"</strong>><strong>/pages/Error.jsp</strong>&lt;/result>
    &lt;result name="invalid.token">/pages/Error.jsp&lt;/result>
    &lt;result name="login" type="redirect-action">Logon!input&lt;/result>
    &lt;/global-results></code></pre>
<hr/>

<p>
    Of course, if an individual action mapping defines its own "error" result type,
    the local result would be used instead.
</p>

<h4><a name="ApplicationListener.java" id="ApplicationListener.java">ApplicationListener.java</a>
</h4>

<p>
    The database is exposed as an object stored in application scope.
    The database object is based on an interface.
    Different implementations of the database could be loaded without changing
    the rest of the application.
    But how is the database object loaded in the first place?
</p>

<p>
    The database is created by a custom Listener that we configured in the "web.xml".
</p>

<hr/>
<h5>mailreader2.ApplicationListener</h5>
<pre><code> &lt;listener>
    &lt;listener-class>
    <strong>mailreader2.ApplicationListener</strong>
    &lt;/listener-class>
    &lt;/listener></code></pre>
<hr/>

<p>
    By default, our ApplicationListener loads a <strong>MemoryDatabase</strong>
    implementation of the UserDatabase.
    MemoryDatabase stores the database content as a XML document,
    which is parsed and loaded as a set of nested hashtables.
    The outer table is the list of user objects, each of which has its own
    inner hashtable of subscriptions.
    When you register, a user object is stored in this hashtable.
    When you login, the user object is stored within the session context.
</p>

<p>
    The database comes seeded with a sample user.
    If you check the "database.xml" file under "/src/main",
    you'll see the sample user described in XML.
</p>

<hr/>
<h5>The "seed" user element from the MailReader database.xml</h5>
<pre><code>&lt;user username="<strong>user</strong>" fromAddress="John.User@somewhere.com"
    fullName="<strong>John Q. User</strong>" password="<strong>pass</strong>">
    &lt;subscription host="<strong>mail.hotmail.com"</strong> autoConnect="false"
    password="bar" type="pop3" username="user1234">
    &lt;/subscription>
    &lt;subscription host="<strong>mail.yahoo.com</strong>" autoConnect="false" password="foo"
    type="imap" username="jquser">
    &lt;/subscription>
    &lt;/user></code></pre>
<hr/>

<p>
    The "seed" user element creates a registration record for "John Q. User",
    with the subscription detail for his hotmail and yahoo accounts.
</p>

<h4><a name="resources.properties" id="resources.properties">Message Resources</a>
</h4>

<p>
    As mentioned, MailReader is an internationalized application.
    The message resources for the application are loaded through a reference in the
    "struts.properties" file.
    Like the database contents, the "struts.properties" file is kept under
    "/src/main/" in the source tree.
</p>

<hr/>
<h5>struts.properties</h5>
<pre><code>struts.custom.i18n.resources = <strong>resources</strong>
    struts.action.extension = <strong>do</strong></code></pre>
<hr/>

<p>
    When we specify "resources" in the properties file,
    we are telling the framework to scan the classpath
    for a Resource Bundle named "resources.properties".
    The bundle might be embedded in a JAR, or found in the "WEB-INF/classes"
    folder, or anywhere else on the runtime classpath.
    In the MailReader, we keep the <strong>original</strong> bundle in the
    source tree under "src/main/". When the application is built, the
    properties files are <strong>copied</strong> to "WEB-INF/classes", so
    that they are on the Java classpath.
</p>

<hr/>
<h5>Message Resource entries used by the Welcome page</h5>
<pre><code><strong>index.heading=</strong>MailReader Application Options
    <strong>index.logon=</strong>Log on to the MailReader Application
    <strong>index.registration=</strong>Register with the MailReader Application
    <strong>index.title=</strong>MailReader Demonstration Application
    <strong>index.tour=</strong>A Walking Tour of the MailReader Demonstration Application</code></pre>
<hr/>

<p>
    If you change a message in the resource, and then rebuild and reload the
    application, the change will appear throughout the application.
    If you provide message resources for additional locales, you can
    localize your application.
    The MailReader provides resources for English, Russian, and Japanese.
</p>

<h4><a name="Welcome.jsp" id="Welcome.jsp">Welcome Page</a></h4>

<p>
    After confirming that the necessary resources exist, the Welcome action
    forwards to the Welcome page.
</p>
<hr/>
<h5>Welcome.jsp</h5>
<pre><code>&lt;%@ page contentType="text/html; charset=UTF-8" %>
    <strong>&lt;%@ taglib prefix="s" uri="http://struts.apache.org/tags" %></strong>
    &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    &lt;html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    &lt;head>
    &lt;meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    &lt;title><strong>&lt;s:text name="index.title"/></strong>&lt;/title>
    &lt;link href="<strong>&lt;s:url value="/css/mailreader.css"/></strong>" rel="stylesheet"
    type="text/css"/>
    &lt;/head>

    &lt;body>
    &lt;h3>&lt;s:text name="index.heading"/>&lt;/h3>

    &lt;ul>
    &lt;li>&lt;a href="&lt;s:url action="Registration!input"/>">&lt;s:text
    name="index.registration"/>&lt;/a>&lt;/li>
    &lt;li>&lt;a href="&lt;s:url action="Logon!input"/>">&lt;s:text
    name="index.logon"/>&lt;/a>&lt;/li>
    &lt;/ul>

    &lt;h3>Language Options&lt;/h3>
    &lt;ul>
    &lt;li>&lt;a href="&lt;s:url action="Welcome?request_locale=en"/>">English&lt;/a>&lt;/li>
    &lt;li>&lt;a href="&lt;s:url action="Welcome?request_locale=ja"/>">Japanese&lt;/a>&lt;/li>
    &lt;li>&lt;a href="&lt;s:url action="Welcome?request_locale=ru"/>">Russian&lt;/a>&lt;/li>
    &lt;/ul>

    &lt;hr />

    &lt;p><strong>&lt;s:i18n name="alternate"></strong>
    &lt;img src="&lt;s:text name="struts.logo.path"/>"
    alt="&lt;s:text name="struts.logo.alt"/>"/>
    <strong>&lt;/s:i18n></strong>&lt;/p>

    &lt;p>&lt;a href="&lt;s:url action="Tour" />">&lt;s:text name="index.tour"/>&lt;/a>&lt;/p>

    &lt;/body>
    &lt;/html></code></pre>
<hr/>

<p>
    At the top of the Welcome page, there are several directives that load the
    Struts 2 tag libraries.
    These are just the usual red tape that goes with any JSP file.
    The rest of the page utilizes three Struts JSP tags:
    "text", "url", and "i18n".
</p>

<p>
    (We use the tag prefix "s:" in the Struts 2 MailReader application,
    but you can use whatever prefix you like in your applications.)
</p>

<p>
    The <strong>text</strong> tag inserts a message from an
    application's default resource bundle.
    If the framework's locale setting is changed for a user,
    the text tag will render messages from the new locale's resource
    bundle instead.
</p>

<p>
    The <strong>url</strong> tag can render a reference to an
    action or any other web resource,
    applying "URL encoding" to the hyperlinks as needed.
    Java's URL encoding feature lets your application maintain client state
    without requiring cookies.
</p>

<hr/>
<h5>Tip:</h5>
<blockquote>
    <p><font class="hint">
        <strong>Cookies</strong> -
        If you turn cookies off in your browser, and then reload your browser
        and this page,
        you will see the links with the Java session id information attached.
        (If you are using Internet Explorer and try this,
        be sure you reset cookies for the appropriate security zone,
        and that you disallow "per-session" cookies.)
    </font></p>
</blockquote>
<hr/>

<p>
    The <strong>i18n</strong> tag provides access to multiple resource bundles.
    The MailReader application uses a second set of message resources for
    non-text elements.
    When these are needed, we use the "i18n" tag to specify a different bundle.
</p>

<p>
    The <strong>alternate</strong> bundle is stored next to the default bundle,
    so that it ends up under "classes", which is on the application's class path.
</p>

<p>
    In the span of a single request for the Welcome page, the framework has done
    quite a bit already:
</p>

<ul>
    <li>
        Confirmed that required resources were loaded during initialization.
    </li>

    <li>
        Written all the page headings and labels from internationalized
        message resources.
    </li>

    <li>
        Automatically URL-encoded paths as needed.
    </li>
</ul>

<p>
    When rendered, the Welcome page lists two menu options:
    one to register with the application and one to log on (if you have
    already registered).
    Let's follow the Logon link first.
</p>

<h3><a name="Logon" id="Logon">Logon</a></h3>

<p>
    If you choose the Logon link, and all goes well, the Logon action forwards
    control to the Logon page.
</p>

<h4><a name="Logon.jsp" id="Logon.jsp">Logon Page</a></h4>

<p>
    The Logon page displays a form that accepts a username and password.
    You can use the default username and password to logon
    (<strong>user</strong> and <strong>pass</strong>), if
    you like. Try omitting or misspelling the username and password in
    various combinations to see how the application reacts.
    Note that both the username and password are case sensitive.
</p>

<hr/>
<h5>Login.jsp</h5>
<pre><code>&lt;%@ page contentType="text/html; charset=UTF-8" %>
    &lt;%@ taglib prefix="s" uri="http://struts.apache.org/tags" %>
    &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    &lt;html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    &lt;head>
    &lt;title>&lt;s:text name="logon.title"/>&lt;/title>
    &lt;link href="&lt;s:url value="/css/mailreader.css"/>" rel="stylesheet"
    type="text/css"/>
    &lt;/head>
    &lt;body onLoad="self.focus();document.Logon.username.focus()">
    <strong>&lt;s:actionerror/></strong>
    <strong>&lt;s:form method="POST" validate="true"></strong>
    <strong>&lt;s:textfield label="%{getText('username')}" name="username"/></strong>
    <strong>&lt;s:password label="%{getText('password')}" name="password"/></strong>
    <strong>&lt;s:submit value="%{getText('button.save')}"/></strong>
    <strong>&lt;s:reset value="%{getText('button.reset')}"/></strong>
    &lt;s:submit <strong>action="Logon!cancel" onclick="form.onsubmit=null"</strong>
    value="%{getText('button.cancel')}"/>
    &lt;/s:form>
    &lt;jsp:include page="Footer.jsp"/>
    &lt;/body>
    &lt;/html></code></pre>
<hr/>

<p>
    We already saw some of the tags used by the Logon page on the Welcome page.
    Let's focus on the new tags.
</p>

<p>
    The first new tag on the Logon page is <strong>actionerrors</strong>.
    Most of the possible validation errors are related to a single field.
    If you don't enter a username,
    the framework can place an error message near the tag prompting you to
    enter a username.
    But some messages are not related to a single field.
    For example, the database might be down.
    If the action returns an "Action Error", as opposed to a "Field Error",
    the messages are rendered in place of the "actionerror" tag.
    The text for the validation errors, whether they are Action Errors or
    Field Errors, can be specified in the resource bundle,
    making the messages easy to manage and localize.
</p>

<p>
    The second new tag is <strong>form</strong>.
    This tag renders a HTML form tag.
    By default, the form will submit back to whatever action invoked the page.
    The "validate=true" setting enables client-side validation,
    so that the form can be validated with JavaScript before being sent
    back to the server.
    The framework will still validate the form again, just to be sure, but the
    client-side validation can save a few round-trips to the server.
    You can use the method attribute to designate "GET" or "POST",
    just like the HTML form tag.
</p>

<p>
    Within the form tag,
    we see four more new tags: "textfield", "password", "submit",
    and "reset". We also see a second usage of "submit" that utilizes an
    "action" attribute.
</p>

<p>
    When we place a control on a form, we usually need to code a set of
    HTML tags to do everything we want to do.
    Most often, we do not just want a plain "input type=text" tag.
    We want the input field to have a label too, and maybe even
    a tooltip. And, of course, a place to print a message
    should invalid data be entered.
</p>

<p>
    The UI Tags support templates and themes so that a set of HTML tags can be
    rendered from a single UI Tag. For example, the single tag
</p>

<pre><code>
    &lt;s:<strong>textfield</strong> label="%{getText('username')}" name="username"/>
</code></pre>

<p>
    generates a wad of HTML markup.
</p>

<hr/>
<pre><code>&lt;tr>
    &lt;td class="tdLabel">
    &lt;label for="Logon_username" class="label">Username:&lt;/label>
    &lt;/td>
    &lt;td>
    &lt;input type="text" name="username" value="" id="Logon_username"/>
    &lt;/td>
    &lt;/tr></code></pre>
<hr/>

<p>
    If for some reason you don't like the markup generated by a UI Tag,
    it's each to change.
    Each tag is driven by a template that can be updated on a tag-by-tag basis.
    For example,
    here is the default template that generates the markup for the ActionErrors tag:
</p>

<hr/>
<pre><code>&lt;#if (actionErrors?exists && actionErrors?size > 0)>
    &lt;ul>
    &lt;#list actionErrors as error>
    &lt;li>&lt;span class="errorMessage">${error}&lt;/span>&lt;/li>
    &lt;/#list>
    &lt;/ul>
    &lt;/#if></code></pre>
<hr/>

<p>
    If you wanted ActionErrors displayed in a table instead of a list,
    you could edit a copy of this file, save it as a file named "actionerror.ftl",
    and place this one file somewhere on your classpath.
</p>

<hr/>
<pre><code>&lt;#if (actionErrors?exists && actionErrors?size > 0)>
    <strong>&lt;table></strong>
    &lt;#list actionErrors as error>
    <strong>&lt;tr>&lt;td></strong>&lt;span class="errorMessage">${error}&lt;/span><strong>&lt;/td>&lt;/tr></strong>
    &lt;/#list>
    <strong>&lt;/table></strong>
    &lt;/#if></code></pre>
<hr/>

<p>
    Under the covers, the framework uses
    <a href="http://freemarker.sourceforge.net/">Freemarker</a>
    for its standard templating language.
    FreeMarker is similar to
    <a href="http://jakarta.apache.org/velocity/">Velocity</a>,
    but it offers better error reporting and some additional features.
    If you prefer, Velocity and JSP templates can also be used to create your own UI Tags.
</p>

<p>
    The <strong>password</strong> tag renders a "input type=password"
    tag, along with the usual template/theme markup.
    By default, the password tag will not retain input if the submit fails.
    If the username is wrong,
    the client will have to enter the password again too.
    (If you did want to retain the password when validation fails,
    you can set the tag's "showPassword" property to true.)
</p>

<p>
    Unsurprisingly, the <strong>submit</strong> and <strong>reset</strong> tags
    render buttons of the corresponding types.
</p>

<p>
    The second submit button is more interesting.
</p>

<pre><code>  &lt;s:submit <strong>action="Logon!cancel" onclick="form.onsubmit=null"</strong>
    value="%{getText('button.cancel')}"/>
</code></pre>

<p>
    Here we are creating the Cancel button for the form.
    The button's attribute <em>action="Logon<strong>!</strong>cancel"</em>
    tells the framework to submit to the Logon's "cancel" method
    instead of the usual "execute" method.
    The <em>onclick="form.onsubmit=null"</em> script defeats client-side validation.
    On the server side, "cancel" is on a special list of methods that bypass validation,
    so the request will go directly to the Action's <strong>cancel</strong> method.
    (Other special aliases on the bypass list include "input" and "back".)
</p>

<hr/>
<h5>Tip:</h5>
<blockquote>
    <p><font class="hint">
        The UI tags have options and capabilities beyond what we have shown here.
        For more see, the <a href="http://confluence.twdata.org/display/WW/Tags">UI Tag documentation.</a>
    </font></p>
</blockquote>
<hr/>

<p>
    OK, but how do the tags know that both of these fields are required?
    How do they know what message to display when the fields are empty?
</p>

<p>
    For the answers, we need to look at another flavor of configuration file:
    the "validation" file.
</p>

<h4><a name="Logon-validation.xml" id="Logon-validation.xml">Logon-validation.xml</a>
</h4>

<p>
    While it is not hard to code data-entry validation into an Action class,
    the framework provides an even easier way to validate input.
</p>

<p>
    The validation framework is configured through another XML document, the <strong>
    Logon-validation.xml</strong>.
</p>

<hr/>
<h5>Validation file for Logon Action</h5>
<pre><code>&lt;!DOCTYPE validators PUBLIC "-//OpenSymphony Group//XWork Validator 1.0.2//EN"
    "http://www.opensymphony.com/xwork/xwork-validator-1.0.2.dtd">
    &lt;validators>
    &lt;field name="<strong>username</strong>">
    &lt;field-validator type="<strong>requiredstring</strong>">
    &lt;message key="<strong>error.username.required</strong>"/>
    &lt;/field-validator>
    &lt;/field>
    &lt;field name="<strong>password</strong>">
    &lt;field-validator type="<strong>requiredstring</strong>">
    &lt;message key="<strong>error.password.required</strong>"/>
    &lt;/field-validator>
    &lt;/field>
    &lt;/validators>
</code></pre>
<hr/>

<p>
    You may note that the DTD refers to "XWork".
    <a href="http://www.opensymphony.com/xwork/">
        Open Symphony XWork
    </a> is a generic command-pattern framework that can be used outside of a
    web environment. In practice, Struts 2 is a web-based extension of the
    XWork framework.
</p>

<p>
    The field elements correspond to the ActionForm properties.
    The <strong>username</strong> and <strong>password</strong> field elements
    say that each field depends on the "requiredstring" validator.
    If the username is blank or absent, validation will fail and an error
    message is generated.
    The messages would be based on the "error.username.required" or
    "error.password.required" message templates, from the resource bundle.
</p>

<!--
<p>
    The <strong>password</strong> field (or property) is also required.
    In addition, it must also pass the "maxlength" and "minlength"
    validations.
    Here, the minimum length is three characters and the maximum length is
    sixteen.
    If the length of the password doesn't meet these criteria, a corresponding
    error message is generated.
    Of course, the messages are generated from the MessageResource bundles and
    are easy to localize.
</p>
-->

<h4><a name="Logon.java" id="Logon.java">Logon Action</a></h4>

<p>
    If validation passes, the framework invokes the "execute" method of the Logon Action.
    The actual Logon Action is brief, since most of the functionality derives
    from the base class, <strong>MailreaderSupport</strong>.
</p>

<hr/>
<h5>Logon.java</h5>
<pre><code>package mailreader2;
    import org.apache.struts.apps.mailreader.dao.User;
    public final class <strong>Logon</strong> extends MailreaderSupport {
    public String <strong>execute()</strong> throws ExpiredPasswordException {
    User user = <strong>findUser(getUsername(), getPassword());</strong>
    if (user != null) {
    <strong>setUser(user);</strong>
    }
    if (<strong>hasErrors()</strong>) {
    return INPUT;
    }
    return SUCCESS;
    }
    }</code></pre>
<hr/>

<p>
    Logon lays out what we do to authenticate a user.
    We try to find the user using the credentials provided.
    If the user is found, we cache a reference.
    If the user is not found, we return "input" so the client can try again.
    Otherwise, we return "success", so that the client can access the rest of the application.
</p>

<h4><a name="MailreaderSupport.java" id="MailreaderSupport.java">MailreaderSupport.java</a></h4>

<p>
    Let's look at the relevant properties and methods from MailreaderSupport
    and another base class, <strong>ActionSupport</strong>, namely
    "getUsername", "getPassword", "findUser", "setUser", and "hasErrors".
</p>

<p>
    The framework lets you define
    <a href="http://struts.apache.org/primer.html#javabeans">JavaBean properties</a>
    directly on the Action.
    Any JavaBean property can be used, including rich objects.
    When a request comes in,
    any public properties on the Action class are matched with the request parameters.
    When the names match, the request parameter value is set to the JavaBean property.
    The framework will make its best effort to convert the data,
    and, if necessary, it will report any conversion errors.
</p>

<p>
    The <strong>Username</strong> and <strong>Password</strong> properties are nothing fancy,
    just standard JavaBean properties.
</p>

<hr/>
<h5>MailreaderSupport.getUsername() and getPassword()</h5>
<pre><code>private String username = null;
    public String <strong>getUsername()</strong> {
    return this.username;
    }
    public void setUsername(String username) {
    this.username = username;
    }

    private String password = null;
    public String <strong>getPassword()</strong> {
    return this.password;
    }
    public void setPassword(String password) {
    this.password = password;
    }</code></pre>
<hr/>

<p>
    We use these properties to capture the client's credentials,
    and pass them to the more interesting <strong>findUser</strong> method.
</p>

<hr/>
<h5>MailreaderSupport.findUser</h5>
<pre><code>public User <strong>findUser</strong>(String username, String password)
    throws <strong>ExpiredPasswordException</strong> {
    User user = <strong>getDatabase().findUser(username)</strong>;
    if ((user != null) && !user.getPassword().equals(password)) {
    user = null;
    }
    if (user == null) {
    this.<strong>addFieldError</strong>("password", getText("error.password.mismatch"));
    }
    return user;
    }</code></pre>
<hr/>

<p>
    The "findUser" method dips into the MailReader Data Access Object layer,
    which is represented by the <strong>Database</strong> property.
    The code for the DAO layer is maintained as a separate component.
    The MailReader application imports the DAO JAR,
    but it is not responsible for maintaining any of the DAO source.
    Keeping the data access layer at "arms-length" is a very good habit.
    It encourages a style of development where the data access layer
    can be tested and developed independently of a specific end-user application.
    In fact, there are several renditions of the MailReader application,
    all which share the same MailReader DAO JAR!
</p>

<hr/>
<h5>Best Practice:</h5>
<blockquote>
    <p><font class="hint">"Strongly separate data access and business logic from the rest of the application."</font>
    </p>
</blockquote>
<hr/>

<p>
    When "findUser" returns,
    the Logon Action looks to see if a valid (non-null) User object is returned.
    A valid User is passed to the <strong>User property</strong>.
    Although it is still a JavaBean property,
    the User property is not implemented in quite the same way as Username and Password.
</p>

<hr/>
<h5>MailreaderSupport.setUser</h5>
<pre><code>public User getUser() {
    return (User) <strong>getSession().get(Constants.USER_KEY)</strong>;
    }
    public void setUser(User user) {
    getSession().put(Constants.USER_KEY, user);
    }</code></pre>
<hr/>

<p>
    Instead of using a field to store the property value,
    "setUser" passes it to a <strong>Session</strong> property.
</p>

<hr/>
<h5>MailreaderSupport.getSession() and setSession()</h5>
<pre><code>private Map session;
    public Map <strong>getSession()</strong> {
    return session;

    public void <strong>setSession(Map value)</strong> {
    session = value;
    }</code></pre>
<hr/>

<p>
    To look at the MailreaderSupport class, you would think the Session property is a plain-old Map.
    In fact, the Session property is an adapter that is backed by the servlet session object at runtime.
    The MailreaderSupport class doesn't need to know that though.
    It can treat Session like any other Map.
    We can also test the MailreaderSupport class by passing it some other implementation of Map,
    running the test,
    and then looking to see what changes MailreaderSupport made to our "mock" Session object.
</p>

<p>
    But, when MailreaderSupport is running inside a web application,
    how does it acquire a reference to the servlet session?
</p>

<p>
    Good question. If you were to look at just the MailreaderSupport class,
    you would not see a single line of code that sets the session property.
    But, yet, when we run the class, the session property is not null.
    Hmmm.
</p>

<p>
    The magic that provides the Session property a runtime value is called "dependency injection".
    The MailreaderSupport class implements a interface called <strong>SessionAware</strong>.
    SessionAware is bundled with the framework, and it defines a setter for the Session property.
</p>

<p>
    <code>public void <strong>setSession</strong>(Map session);</code>
</p>

<p>
    Also bundled with the framework is an object called the <strong>ServletConfigInterceptor</strong>.
    If the ServletConfigInterceptor sees that an Action implements the SessionAware interface,
    it automatically set the session property.
</p>

<pre><code>if (action instanceof <code>SessionAware</code>) {
    ((SessionAware) action).<code>setSession</code>(context.getSession());
    }</code></pre>

<p>
    The framework uses these "Interceptor" classes to create a <strong>front controller</strong>
    for each action an application defines.
    Each Interceptor can peek at the request before an Action class is invoked,
    and then again after the Action class is invoked.
    (If you have worked with Servlet
    <a href="http://struts.apache.org/primer.html#filters">Filters</a>,
    you will recognize this pattern.
    But, unlike Filters, Interceptors are not tied to HTTP.
    Interceptors can be tested and developed outside of a web application.)
</p>

<p>
    You can use the same set of Interceptors for all your actions,
    or define a special set of Interceptors for any given action,
    or define different sets of Interceptors to use with different types of actions.
    The framework comes with a default set of Interceptors,
    that it will use when another set is not specified,
    but you can designate your own default Interceptor set (or "stack")
    in the struts.xml configuration file.
</p>

<p>
    Many Interceptors provide a utility or helper functions, like setting the session property.
    Others, like the <strong>ValidationInterceptor</strong>, can change the workflow of an action.
    Interceptors are key feature of the framework,
    and we will see a few more on the tour.
</p>

<p>
    If a valid User is not found, or the password doesn't match,
    the "findUser" method invokes the <strong>addFieldError</strong> method to note the problem.
    When "findUser" returns, the Logon Action checks for errors,
    and then it returns either INPUT or SUCCESS.
</p>

<p>
    The "addFieldError" method is provided by the ActionSupport class,
    which is bundled with the framework.
    The constants for INPUT and SUCCESS are also provided by ActionSupport.
    While the ActionSupport class provides many useful utilities,
    you are not required to use it as a base class.
    Any Java class can be used as an Action, if you like.
</p>

<p>
    It is a good practice to provide a base class with utilities
    that can be shared by an application's Action classes.
    The framework does this with ActionSupport,
    and the MailReader application does the same with the MailreaderSupport class.
</p>

<hr/>
<h5>Best Practice:</h5>
<blockquote>
    <p><font class="hint">"Use a base class to define common functionality."</font></p>
</blockquote>
<hr/>

<p>
    But, what happens if Logon returns INPUT instead of SUCCESS.
    How does the framework know what to do next?
</p>

<p>
    To answer that question,
    we need to turn back to the "struts.xml" file and look at how Logon is configured.
</p>


<h4><a name="Logon.xml" id="Logon.xml">Logon Configuration</a></h4>

<p>
    The Logon action element outlines how the Logon workflow operates,
    including what to do when the Action returns "input",
    or the default result name "success".
</p>

<hr/>
<h5>struts.xml Logon</h5>
<pre><code>&lt;action name="<strong>Logon</strong>" class="mailreader2.registration.Retrieve">
    &lt;result name="<strong>input</strong>">/pages/Logon.jsp&lt;/result>
    &lt;result name="<strong>cancel</strong>" type="redirect-action">Welcome&lt;/result>
    &lt;result type="redirect-action">MainMenu&lt;/result>
    &lt;result name="<strong>expired</strong>" type="chain">ChangePassword&lt;/result>
    &lt;<strong>exception-mapping</strong>
    exception="org.apache.struts.apps.mailreader.dao.ExpiredPasswordException"
    result="<strong>expired</strong>"/>
    &lt;interceptor-ref name="<strong>guest</strong>"/>
    &lt;/action></code></pre>
<hr/>

<p>
    In the Logon action element, the first result element is named "input".
    If validation or authentification fail,
    the Action class will return "input" and the framework will transfer control to the
    "Logon.jsp" page.
</p>

<p>
    The second result element is named <strong>cancel</strong>.
    If someone presses the cancel button on the Logon page,
    the Action class will return "cancel", this result will be selected,
    and the framework will issue a redirect to the Welcome action.
</p>

<p>
    The third result has no name,
    so it will be called if the default <strong>success</strong> token is returned.
    So, if the Logon succeeds,
    control will transfer to the MainMenu action.
</p>

<p>
    The MailReader DAO exposes a "ExpiredPasswordException".
    If the DAO throws this exception when the User logs in,
    the framework will process the exception-mapping
    and transfer control to the "ChangePassword" action.
</p>

<p>
    Just in case any other Exceptions are thrown,
    the MailReader application also defines a global handler.
</p>

<hr/>
<h5>struts.xml exception-mapping</h5>
<pre><code>&lt;global-exception-mappings>
    &lt;exception-mapping
    result="error"
    exception="java.lang.Exception"/>
    &lt;/global-exception-mappings></code></pre>
<hr/>

<p>
    If an unexpected Exception is thrown,
    the exception-mapping will transfer control to the action's "error" result,
    or to a global "error" result.
    The MailReader defines a global "error" result
    which transfers control to an "Error.jsp" page
    that can display the error message.
</p>

<hr/>
<h5>Error.jsp</h5>
<pre><code>&lt;%@ page contentType="text/html; charset=UTF-8" %>
    &lt;%@ taglib prefix="s" uri="http://struts.apache.org/tags" %>
    &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    &lt;html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    &lt;head>
    &lt;title>Unexpected Error&lt;/title>
    &lt;/head>
    &lt;body>
    &lt;h2>An unexpected error has occured&lt;/h2>
    &lt;p>
    Please report this error to your system administrator
    or appropriate technical support personnel.
    Thank you for your cooperation.
    &lt;/p>
    &lt;hr />
    &lt;h3>Error Message&lt;/h3>
    <strong>&lt;s:actionerror /></strong>
    &lt;p>
    <strong>&lt;s:property value="%{exception.message}"/></strong>
    &lt;/p>
    &lt;hr />
    &lt;h3>Technical Details&lt;/h3>
    &lt;p>
    <strong>&lt;s:property value="%{exceptionStack}"/></strong>
    &lt;/p>
    &lt;jsp:include page="Footer.jsp"/>
    &lt;/body>
    &lt;/html></code></pre>
<hr/>

<p>
    The Error page uses <strong>property</strong> tags to expose
    the Exception message and the Exception stack.
</p>

<p>
    Finally, the Logon action specifies an <strong>InterceptorStack</strong>
    named <strong>defaultStack.</strong>
    If you've worked with Struts 2 or WebWork 2 before, that might seem strange,
    since "defaultStack" is the factory default.
</p>

<p>
    In the MailReader application, most of the actions are only available
    to authenticated users.
    The exceptions are the Welcome, Logon, and Register actions
    which are available to everyone.
    To authenticate clients,
    the MailReader uses a custom Interceptor and a custom Interceptor stack.
</p>

<hr/>
<h5>mailreader2.AuthenticationInterceptor</h5>
<pre><code>package mailreader2;
    import com.opensymphony.xwork2.interceptor.Interceptor;
    import com.opensymphony.xwork2.ActionInvocation;
    import com.opensymphony.xwork2.Action;
    import java.util.Map;
    import org.apache.struts.apps.mailreader.dao.User;

    public class <strong>AuthenticationInterceptor</strong> implements Interceptor {
    public void destroy () {}
    public void init() {}
    public String <strong>intercept</strong>(ActionInvocation actionInvocation) throws Exception {
    Map session = actionInvocation.getInvocationContext().getSession();
    User user = (User) session.get(Constants.USER_KEY);
    boolean isAuthenticated = (null!=user) && (null!=user.getDatabase());
    if (<strong>isAuthenticated</strong>) {
    return actionInvocation.invoke();
    }
    else {
    return Action.LOGIN;
    }
    }
    }</code></pre>
<hr/>

<p>
    The <strong>AuthenticationInterceptor</strong> looks to see if a User object
    has been stored in the client's session state.
    If so, it returns normally, and the next Interceptor in the set would be invoked.
    If the User object is missing, the Interceptors returns "login".
    The framework would match "login" to the global result,
    and transfer control to the Logon action.
</p>

<p>
    The MailReader defines four custom Interceptor stacks: "user", "user-submit",
    "guest", and "guest-submit".
</p>

<hr/>
<h5>struts.xml interceptors</h5>
<pre><code>&lt;interceptors>
    &lt;interceptor name="<strong>authentication</strong>"
    class="mailreader2.AuthenticationInterceptor"/>
    &lt;interceptor-stack name="<strong>user</strong>" >
    &lt;interceptor-ref name="authentication" />
    &lt;interceptor-ref name="defaultStack"/>
    &lt;/interceptor-stack>
    &lt;interceptor-stack name="<strong>user-submit</strong>" >
    &lt;interceptor-ref name="token-session" />
    &lt;interceptor-ref name="user"/>
    &lt;/interceptor-stack>
    &lt;interceptor-stack name="<strong>guest</strong>" >
    &lt;interceptor-ref name="defaultStack"/>
    &lt;/interceptor-stack>
    &lt;interceptor-stack name="<strong>guest-submit</strong>" >
    &lt;interceptor-ref name="token-session" />
    &lt;interceptor-ref name="guest"/>
    &lt;/interceptor-stack>
    &lt;/interceptors>
    &lt;<strong>default-interceptor-ref</strong> name="user"/></code></pre>
<hr/>

<p>
    The <strong>user</strong> stacks require that the client be authenticated.
    In other words, that a User object is present in the session.
    The actions using a <strong>guest</strong> stack can be accessed by any client.
    The <strong>-submit</strong> versions of each can be used with actions
    with forms, to guard against double submits.
</p>

<h5>Double Submits</h5>

<p>
    A common problem with designing web applications is that users are impatient
    and response times can vary.
    Sometimes, people will press a submit button a second time.
    When this happens, the browser submits the request again,
    so that we now have two requests for the same thing.
    In the case of registering a user, if someone does press the submit button
    again, and their timing is bad,
    it could result in the system reporting that the username has already been
    used.
    (The first time the button was pressed.)
    In practice, this would probably never happen, but for a longer running
    process, like checking out a shopping cart,
    it's easier for a double submit to occur.
</p>

<p>
    To forestall double submits, and "back button" resubmits,
    the framework can generate a token that is embedded in the form
    and also kept in the session.
    If the value of the tokens do not compare,
    then we know that there has been a problem,
    and that a form has been submitted twice or out of sequence.
</p>

<p>
    The Token Session Interceptor will also attempt to provide intelligent
    fail-over in the event of multiple requests using the same session.
    That is, it will block subsequent requests until the first request is complete,
    and then instead of returning the "invalid.token" code,
    it will attempt to display the same response that the
    original, valid action invocation would have displayed
</p>

<p>
    Because the default interceptor stack will now authenticate the client,
    we need to specify the standard "defaultStack" for the three
    "guest actions", Welcome, Logon, and Register.
    Requiring authentification by default is the better practice, since it
    means that we won't forget to enable it when creating new actions.
    Meanwhile, those pesky users will ensure that we don't forget to disable
    authentification for "guest" services.
</p>

<h3><a name="MainMenu" id="MainMenu">MainMenu</a></h3>

<p>
    On a successful logon, the Main Menu page displays.
    If you logged in using the demo account,
    the page title should be "Main Menu Options for John Q. User".
    Below this legend should be two links:
</p>

<ul>
    <li>
        Edit your user registration profile
    </li>
    <li>
        Log off MailReader Demonstration Application
    </li>
</ul>

<p>
    Let's review the source for the "MainMenu" action mapping,
    and the "MainMenu.jsp".
</p>

<hr/>
<h5>Action mapping element for MainMenu</h5>
<pre><code>&lt;action name="MainMenu" class="mailreader2.MailreaderSupport">
    &lt;result>/pages/MainMenu.jsp&lt;/result>
    &lt;/action></code></pre>

<h5>MainMenu.jsp</h5>
<pre><code>&lt;%@ page contentType="text/html; charset=UTF-8" %>
    &lt;%@ taglib prefix="s" uri="http://struts.apache.org/tags" %>
    &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    &lt;html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    &lt;head>
    &lt;title>&lt;s:text name="mainMenu.title"/>&lt;/title>
    &lt;link href="&lt;s:url value="/css/mailreader.css"/>" rel="stylesheet"
    type="text/css"/>
    &lt;/head>

    &lt;body>
    &lt;h3>&lt;s:text name="mainMenu.heading"/> <strong>&lt;s:property
    value="user.fullName"/></strong>&lt;/h3>
    &lt;ul>
    &lt;li>&lt;a href="&lt;s:url <strong>action="Registration!input"</strong> />">
    &lt;s:text name="mainMenu.registration"/>
    &lt;/a>
    &lt;/li>
    &lt;li>&lt;a href="&lt;s:url <strong>action="Logoff"</strong> />">
    &lt;s:text name="mainMenu.logoff"/>
    &lt;/a>
    &lt;/ul>
    &lt;/body>
    &lt;/html></code></pre>
<hr/>

<p>
    The source for "MainMenu.jsp" also contains a new tag, <strong>
    property</strong>, which we use to customize the page with the
    "fullName" property of the authenticated user.
</p>

<p>
    Displaying the user's full name is the reason the MainMenu action
    references the MailreaderSupport class.
    The MailreaderSupport class has a User property that the text tag
    can access.
    If we did not utilize MailreaderSupport,
    the property tag would not be able to find the User object to print
    the full name.
</p>

<p>
    The customized MainMenu page offers two standard links.
    One is to "Edit your user registration profile".
    The other is to "Logoff the MailReader Demonstration Application".
</p>

<h3><a name="Registration.jsp" id="Registration.jsp">Registration page</a>
</h3>

<p>
    If you follow the "Edit your user registration profile" link from the Main
    Menu page,
    we will finally reach the heart of the MailReader application: the
    Registration, or "Profile", page.
    This page displays everything MailReader knows about you
    (or at least your login),
    while utilizing several interesting techniques.
</p>

<p>
    To do double duty as the "Create" Registration page and the "Edit"
    Registration page,
    the "Registration.jsp" makes extensive use of the test tags,
    to make it appears as though there are two distinct pages.
</p>

<hr/>
<h5>Registration.jsp - head element</h5>
<pre><code>&lt;head>
    &lt;s:if test="<strong>task=='Create'</strong>">
    &lt;title>&lt;s:text name="registration.title.create"/>&lt;/title>
    &lt;/s:if>
    &lt;s:if test="<strong>task=='Edit'</strong>">
    &lt;title>&lt;s:text name="registration.title.edit"/>&lt;/title>
    &lt;/s:if>
    &lt;link href="&lt;s:url value="/css/mailreader.css"/>" rel="stylesheet"
    type="text/css"/>
    &lt;/head></code></pre>
<hr/>

<p>
    For example, if client is editing the form (task == 'Edit'),
    the page inserts the username from the User object.
    For a new Registration (task == 'Create'),
    the page creates an empty data-entry field.
</p>

<hr/>
<h5>Note:</h5>
<blockquote>
    <p><font class="hint">
        <strong>Presention Logic</strong> -
        The "test" tag is a convenient way to express presentation
        logic within your pages.
        Customized pages help to prevent user error,
        and dynamic customization reduces the number of server pages your
        application needs to maintain, among other benefits.
    </font></p>
</blockquote>
<hr/>

<p>
    The page also uses logic tags to display a list of subscriptions
    for the given user.
    If the RegistrationForm has task set to "Edit",
    the lower part of the page that lists the subscriptions is exposed.
</p>

<hr/>
<h5></h5>
<pre><code>&lt;s:if test=<strong>"task == 'Edit'"</strong>>
    &lt;div align="center">
    &lt;h3>&lt;s:text name="heading.subscriptions"/>&lt;/h3>
    &lt;/div>
    &lt;!-- ... -->
    &lt;/s:if>
    &lt;jsp:include page="Footer.jsp"/>
    &lt;/body>&lt;/html></code></pre>
<hr/>

<p>
    Otherwise, the page contains just the top portion --
    a data-entry form for managing the user's registration.
</p>

<h4><a name="iterator" id="iterator">iterator</a></h4>

<p>
    Besides "if" there are several other control tags that you can use
    to sort, filter, or iterate over data.
    The Registration page includes a good example of using the <strong>iterator</strong>
    tag to display the User's Subscriptions.
</p>

<p>
    The subscriptions are stored in a hashtable object, which is in turn
    stored in the user object.
    So to display each subscription, we have to reach into the user object,
    and loop through the members of the subscription collection.
    Using the iterator tag, you can code it the way it sounds.
</p>

<hr/>
<h5>Using iterator to list the Subscriptions</h5>
<pre><code>&lt;s:iterator value="<strong>user.subscriptions</strong>">
    &lt;tr>
    &lt;td align="left">
    &lt;s:property value="<strong>host</strong>"/>
    &lt;/td>
    &lt;td align="left">
    &lt;s:property value="<strong>username</strong>"/>
    &lt;/td>
    &lt;td align="center">
    &lt;s:property value="<strong>type</strong>"/>
    &lt;/td>
    &lt;td align="center">
    &lt;s:property value="<strong>autoConnect</strong>"/>
    &lt;/td>
    &lt;td align="center">
    &lt;a href="&lt;s:url action="<strong>Subscription!delete</strong>">&lt;s:param name="<strong>host</strong>"
    value="host"/>&lt;/s:url>">
    &lt;s:text name="registration.deleteSubscription"/>
    &lt;/a>&nbsp;
    &lt;a href="&lt;s:url action="<strong>Subscription!edit</strong>">&lt;s:param name="<strong>host</strong>"
    value="host"/>&lt;/s:url>">
    &lt;s:text name="registration.editSubscription"/>
    &lt;/a>
    &lt;/td>
    &lt;/tr>
    &lt;/s:iterator></code></pre>
<hr/>

<p>
    When the iterator renders, it generates a list of Subscriptions for the current User.
</p>

<hr/>

<div align="center">
    <h3>Current Subscriptions</h3>
</div>

<table border="1" width="100%">
    <tr>
        <th align="center" width="30%">
            Host Name
        </th>
        <th align="center" width="25%">
            User Name
        </th>

        <th align="center" width="10%">
            Server Type
        </th>
        <th align="center" width="10%">
            Auto
        </th>
        <th align="center" width="15%">
            Action
        </th>
    </tr>
    <tr>
        <td align="left">
            mail.hotmail.com
        </td>
        <td align="left">
            user1234
        </td>
        <td align="center">
            pop3
        </td>

        <td align="center">
            false
        </td>
        <td align="center">
            <a href="/struts2-mailreader/Subscription!delete.do?host=mail.hotmail.com">
                Delete
            </a>
            &nbsp;
            <a href="/struts2-mailreader/Subscription!edit.do?host=mail.hotmail.com">
                Edit
            </a>
        </td>
    </tr>
    <tr>
        <td align="left">
            mail.yahoo.com
        </td>
        <td align="left">
            jquser
        </td>
        <td align="center">
            imap
        </td>
        <td align="center">
            false
        </td>
        <td align="center">
            <a href="/struts2-mailreader/Subscription!delete.do?host=mail.yahoo.com">
                Delete
            </a>
            &nbsp;
            <a href="/struts2-mailreader/Subscription!edit.do?host=mail.yahoo.com">
                Edit
            </a>
        </td>
    </tr>
</table>
<a href="/struts2-mailreader/Subscription!input.do">Add</a>

<hr/>

<p>
    Now look back at the code used to generate this block.
</p>

<p>
    Notice anything nifty?
</p>

<p>
    How about that the markup between the iterator tag is
    actually <em>simpler</em> than the markup that we would use to render one row of the table?
</p>

<p>
    Instead of using a qualified reference like "value=user.subscription[0].host",
    we use the simplest possible reference: "value=host".
    We didn't have to define a local variable, and reference that local in the loop code.
    The reference to each item in the list is automatically resolved, no fuss, no muss.
</p>

<p>
    Nice trick!
</p>

<p>
    The secret to this magic is the <strong>value stack</strong>.
    Next to Interceptors, the value stack is probably the coolest thing there is about the framework.
    To explain the value stack, let's step back and start from the beginning.
</p>

<p>
    Merging dynamic data into static web pages is a primary reason
    we create web applications.
    The Java API has a mechanism that allows you to
    place objects in a servlet scope (page, request, session, or
    application), and then retrieve them using a JSP scriplet.
    If the object is placed directly in one of the scopes,
    a JSP tag or scriptlet can find that object by searching page scope and
    then request scope, and session scope, and finally application scope.
</p>

<p>
    The value stack works much the same way, only better.
    When you push an object on the value stack,
    the public properties of that object become first-class properties of the stack.
    The object's properties become the stack's properties.
    If another object on the stack has properties of the same name,
    the last object pushed onto the stack wins. (Last-In, First-Out.)
</p>

<p>
    When the iterator tag loops through a collection,
    it pushes each item in the collection onto the stack.
    The item's properties become the stack's property.
    In the case of the Subscriptions,
    if the Subscription has a public Host property,
    then during that iteration,
    the stack can access the same property.
</p>

<p>
    Of course, at the end of each iteration, the tag "pops" the item off the stack.
    If we were to try and access the Host property later in the page,
    it won't be there.
</p>

<p>
    When an Action is invoked, the Action class is pushed onto the value stack.
    Since the Action is on the value stack,
    our tags can access any property of the Action as if it were an implicit property of the page.
    The tags don't access the Action directly.
    If a textfield tag is told to render the "Username" property,
    the tag asks the value stack for the value of "Username",
    and the value stack returns the first property it finds by that name.
</p>

<p>
    The Validators also use the stack.
    When validation fails on a field,
    the value for the field is pushed onto the value stack.
    As a result, if the client enters text into an Integer field,
    the framework can still redisplay whatever was entered.
    An invalid input value is not stored in the field (even if it could be).
    The invalid input is pushed onto the stack for the scope of the request.
</p>

<p>
    The Subscription list uses another new tag: the <strong>param</strong> tag.
    As tags go, "param" takes very few parameters of its own: just "name" and "value", and neither is required.
    Although simple, "param" is one of the most powerful tags the framework provides.
    Not so much because of what it does, but because of what "param" allows the other tags to do.
</p>

<p>
    Essentially, the "param" tag provides parameters to other tags.
    A tag like "text" might be retrieving a message template with several replaceable parameters.
    No matter how many parameters are in the template, and no matter what they are named,
    you can use the "param" tag to pass in whatever you need.
</p>

<pre><code>pager.legend = Displaying {current} of {count} items matching {criteria}.
    ...
    &lt;s:text name="pager.legend">
    &lt;s:<strong>param</strong> name="current" value="42" />
    &lt;s:<strong>param</strong> name="count" value="314" />
    &lt;s:<strong>param</strong> name="criteria" value="Life, the Universe, and Everything" />
    &lt;/s:text></code></pre>

<p>
    In the case of an "url" tag,
    we can use "param" to create the query string.
    A statement like this:
</p>

<pre><code>
    &lt;s:url action="Subscription!edit">&lt;s:param name="<strong>host" value="host</strong>"/>&lt;/s:url>">
</code></pre>

<p>
    can render a hyperlink like this:
</p>

<pre><code>
    &lt;a href="/struts2-mailreader/Subscription!edit.do?<strong>host=mail.yahoo.com</strong>">Edit&lt;/a>
</code></pre>


<!--
<p>
    At the foot of the Register page is a link for adding a subscription.
    Let's wind up the tour by following the Add link and then logging off.
    Like the link for creating a Support, Add points to an "Edit" action,
    namely "EditSubscription".
</p>
-->

<p>
    If a hyperlink needs more parameters,
    you can use "param" to add as many parameters as needed.
</p>

<h3>
    <a name="Subscription" id="Subscription">Subscription</a>
</h3>

<p>
    If we follow one of the "Edit" subscription links on the Registration page,
    we come to the Subscriptions page,
    which displays the details of our description in a data-entry form.
    Let's have a look a the Subscription configuration in "struts.xml"
    and follow the bouncing ball from page to action to page.
</p>

<hr/>
<h5>struts.xml Subscription element</h5>
<pre><code>&lt;action name="Subscription" class="mailreader2.SubscriptionSupport">
    &lt;result name="input">/pages/Subscription.jsp&lt;/result>
    &lt;result type="redirect-action">Registration!input&lt;/result>
    &lt;/action></code></pre>
<hr/>

<p>
    The Edit link specified the Subscription action,
    but also includes the qualifier <strong>!edit</strong>.
    The <strong>!</strong> idiom tells the framework to invoke the
    "edit" method of the Subscription action,
    instead of the default "execute" method
    The "alternate" execute methods are called <strong>alias</strong> methods.
</p>

<hr/>
<h5>Subscription edit alias</h5>
<pre><code>public String <strong>edit()</strong> {
    <strong>setTask(Constants.EDIT);</strong>>
    return find();
    }

    public String find() {
    org.apache.struts.apps.mailreader.dao.Subscription
    sub = findSubscription();
    if (sub == null) {
    return ERROR;
    }
    <strong>setSubscription(sub);</strong>
    return INPUT;
    }</code></pre>
<hr/>

<p>
    The "edit" alias has two responsibilities.
    First, it must set the Task property to "Edit".
    The Subscription page will render itself differently
    depending on the value of the Task property.
    Second, "edit" must locate the relevant Subscription
    and set it to the Subscription property.
    If all goes well, "edit" returns the INPUT token,
    so that the "input" result will be invoked.
</p>

<p>
    In the normal course, the Subscription should always be found,
    since we selected the entry from a system-generated list.
    If the Subscription is not found,
    it would be because the database disappeared
    or the request is being spoofed.
    If the Subscription is not found,
    edit returns the token for the global "error" result,
    because this condition is unexpected.
</p>

<p>
    The business logic for the "edit" alias is a simple wrapper
    around the MailReader DAO classes.
</p>

<hr/>
<h5>MailreaderSupport findSubscription()</h5>
<pre><code>public Subscription <strong>findSubscription()</strong> {
    return findSubscription(getHost());
    }

    public Subscription findSubscription(String host) {
    Subscription subscription;
    subscription = <strong>getUser().findSubscription(host);</strong>
    return subscription;
    }</code></pre>
<hr/>

<p>
    This code is very simple
    and doesn't seem to provide much in the way of error handling.
    But, that's OK.
    Since the page is suppose to be entered from a link that we created,
    we do expect everything to go right here.
    But, if it doesn't, the global exception handler we defined in "struts.xml"
    will trap the exception for us.
</p>

<p>
    Likewise, the AuthentificationInterceptor will ensure that only clients
    with a valid User object can try to edit a Subscription.
    If the session expired, or someone bookmarked the page,
    the client will be redirected to the Logon page automatically.
</p>

<p>
    As a final layer of defense, we also configured a validator for Subscription,
    to ensure that we are passed a Host parameter.
</p>

<hr/>
<h5>Subscription-validation.xml</h5>
<pre><code>&lt;!DOCTYPE validators PUBLIC "-//OpenSymphony Group//XWork Validator 1.0.2//EN"
    "http://www.opensymphony.com/xwork/xwork-validator-1.0.2.dtd">
    &lt;validators>
    &lt;field name="<strong>host</strong>">
    &lt;field-validator type="<strong>requiredstring</strong>">
    &lt;message key="error.host.required"/>
    &lt;/field-validator>
    &lt;/field>
    &lt;/validators></code></pre>
<hr/>

<p>
    By keeping routine sety precautions out of the Action class,
    the all-important Actions becomes smaller and easier to maintain.
</p>

<p>
    After setting the relevent Subscription object to the Subscription property,
    the framework transfers control to the (you guessed it) Subscription page.
</p>

<hr/>
<h5>Subscription.jsp</h5>
<pre><code>&lt;%@ page contentType="text/html; charset=UTF-8" %>
    &lt;%@ taglib prefix="s" uri="http://struts.apache.org/tags" %>
    &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    &lt;html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    &lt;head>
    &lt;s:if test="task=='Create'">
    &lt;title>&lt;s:text name="subscription.title.create"/>&lt;/title>
    &lt;/s:if>
    &lt;s:if test="task=='Edit'">
    &lt;title>&lt;s:text name="subscription.title.edit"/>&lt;/title>
    &lt;/s:if>
    &lt;s:if test="task=='Delete'">
    &lt;title>&lt;s:text name="subscription.title.delete"/>&lt;/title>
    &lt;/s:if>
    &lt;link href="&lt;s:url value="/css/mailreader.css"/>" rel="stylesheet"
    type="text/css"/>
    &lt;/head>
    &lt;body onLoad="self.focus();document.Subscription.username.focus()">

    &lt;s:actionerror/>
    &lt;s:form method="POST" <strong>action="SubscriptionSave"</strong> validate="false">
    <strong>&lt;s:token /></strong>
    <strong>&lt;s:hidden name="task"/></strong>
    <strong>&lt;s:label label="%{getText('username')}" name="user.username"/></strong>

    &lt;s:if test="task == 'Create'">
    &lt;s:textfield label="%{getText('mailHostname')}" name="host"/>
    &lt;/s:if>
    &lt;s:else>
    &lt;s:label label="%{getText('mailHostname')}" name="host"/>
    &lt;s:hidden name="host"/>
    &lt;/s:else>

    &lt;s:if test="task == 'Delete'">
    &lt;s:label label="%{getText('mailUsername')}"
    name="subscription.username"/>
    &lt;s:label label="%{getText('mailPassword')}"
    name="subscription.password"/>
    &lt;s:label label="%{getText('mailServerType')}"
    name="subscription.type"/>
    &lt;s:label label="%{getText('autoConnect')}"
    name="subscription.autoConnect"/>
    &lt;s:submit value="%{getText('button.confirm')}"/>
    &lt;/s:if>
    &lt;s:else>
    &lt;s:textfield label="%{getText('mailUsername')}"
    name="subscription.username"/>
    &lt;s:textfield label="%{getText('mailPassword')}"
    name="subscription.password"/>
    <strong>&lt;s:select label="%{getText('mailServerType')}"
        name="subscription.type" list="types"/></strong>
    <strong>&lt;s:checkbox label="%{getText('autoConnect')}"
        name="subscription.autoConnect"/></strong>
    &lt;s:submit value="%{getText('button.save')}"/>
    &lt;s:reset value="%{getText('button.reset')}"/>
    &lt;/s:else>

    &lt;s:submit action="Registration!input"
    value="%{getText('button.cancel')}"
    onclick="form.onsubmit=null"/>
    &lt;/s:form>

    &lt;jsp:include page="Footer.jsp"/>
    &lt;/body>
    &lt;/html></code></pre>
<hr/>

<p>
    As before, we'll discuss the tags and attributes that are new to this page:
    "token", "hidden", "label", "select", and "checkbox".
</p>

<p>
    When we looked at the form tag for the Logon page,
    it did not specify a target for the submit.
    Instead, it just posted back to the Logon action.
    In this <strong>form</strong> tag, we are specifying a different action,
    <strong>SubscriptionSave</strong>
    to be the target of the submit,
</p>

<p>
    The main reason we use another action is so that we can use a different set of validations.
    When we retrieve the Subscription for editing, all we need is the Host property.
    When we save the Subscription, we want to validate additional properties.
    Since the validation files are coupled to the classes,
    we created a new Action class for saving a Subscription.
</p>

<hr/>
<h5>Subscription-validation.xml</h5>
<pre><code>&lt;!DOCTYPE validators PUBLIC "-//OpenSymphony Group//XWork Validator 1.0.2//EN"
    "http://www.opensymphony.com/xwork/xwork-validator-1.0.2.dtd">
    &lt;validators>
    &lt;field name="<strong>host</strong>">
    &lt;field-validator type="<strong>requiredstring</strong>">
    &lt;message key="error.host.required"/>
    &lt;/field-validator>
    &lt;/field>
    &lt;/validators></code></pre>
<hr/>

<p>
    The validators follow the same type of inheritance path as the classes.
    SubscriptionSave extends Subscription,
    so when SubscriptionSave is validated,
    the Host property specified by "Subscription-validation.xml" will also be required.
</p>

<p>
    The <strong>token</strong> tag works with the Token Session Interceptor to foil double submits.
    The tag generates a key that is embedded in the form and cached in the session.
    Without this tag, the Interceptor can't work it's magic.
</p>

<p>
    The <strong>hidden</strong> tag embeds the Task property into the form.
    When the form is submitted,
    the SubscriptionSave action wil use the Task property to decide
    whether to insert or update the form.
</p>

<p>
    The <strong>label</strong> renders a "read only" version of a property,
    suitable for placement in the form.
    In Edit or Delete mode, we want the Host property to be immutable,
    since it is used as a key. (As unwise as that might sound.)
    In Delete mode, all of the properties are immutable,
    since we are simply confirming the delete operation.
</p>

<p>
    Saving the best for last, the Subscription utilizes two more interesting
    tags, "select" and "checkbox".
</p>

<p>
    Unsurprisingly, the <strong>select</strong> tag renders a select control,
    but the tag does so without requiring a lot of markup or redtape.
</p>

<pre><code>&lt;s:select label="%{getText('mailServerType')}"
    name="subscription.type" <strong>list="types"</strong> />
</code></pre>

<p>
    The interesting attribute of the "select" tag is "list",
    which, in our case, specifies a value of "types".
    If we take another look at the Subscription action,
    we can see that it implements an interface named Preparable
    and populates a Types property in a method named "prepare".
</p>

<hr/>
<h5>Subscription-validation.xml</h5>
<pre><code>public class <strong>Subscription</strong> extends MailreaderSupport
    <strong>implements Preparable</strong> {

    private Map types = null;
    public Map <strong>getTypes()</strong> {
    return types;
    }

    public void <strong>prepare()</strong> {
    Map m = new LinkedHashMap();
    m.put("imap", "IMAP Protocol");
    m.put("pop3", "POP3 Protocol");
    types = m;
    setHost(getSubscriptionHost());
    }

    // ... </code></pre>
<hr/>

<p>
    The default Interceptor stack includes the <strong>PrepareInterceptor</strong>,
    which observes the Preparable interface.
</p>

<hr/>
<h5>PrepareInterceptor</h5>
<pre><code>public class <strong>PrepareInterceptor</strong> extends AroundInterceptor {

    protected void after(ActionInvocation dispatcher, String result) throws Exception {
    }

    protected void before(ActionInvocation invocation) throws Exception {
    Object action = invocation.getAction();
    <strong>if (action instanceof Preparable) {
        ((Preparable) action).prepare();</strong>
    }
    }
    }</code></pre>

<p>
    The PrepareInterceptor ensures that the "prepare" method will always be called
    before "execute" or an alias method is invoked.
    We use "prepare" to setup the list of items for the select list to display.
    We also transfer the Host property from our Subscription object
    to a local property, where it is easier to manage.
</p>


<h4>
    <a name="SubscriptionAction.java" id="SubscriptionAction.java">SubscriptionAction.java</a>
</h4>

<p>
    Like many applications, the MailReader uses mainly String properties.
    One exception is the AutoConnect property of the Subscription object.
    On the HTML form, the AutoConnect property is represented by a checkbox,
    and checkboxes need to be handled differently that other controls.
</p>

<p>
    The <strong>checkbox</strong> starts out as a simple enough control.
</p>

<pre><code>  &lt;s:checkbox label="%{getText('autoConnect')}"
    name="subscription.autoConnect"/></code></pre>

<p>
    The Subscription object has a boolean AutoConnect property,
    and the checkbox simply has to represent its state.
    The problem is, if you clear a checkbox, the browser client will not submit <em>anything</em>.
    Nada. Zip.
    It is as if the checkbox control never existed.
    The HTTP protocol has no way to affirm "false".
    If the control is missing, we need to figure out it's been unclicked.
</p>

<hr/>
<h5>Tip:</h5>
<blockquote>
    <p class="hint">
        <strong>Checkboxes</strong> -
        The HTML checkbox is a tricky control.
        The problem is that, according to the W3C specification, a value is
        only guaranteed to be sent
        if the control is checked.
        If the control is not checked, then the control may be omitted from
        the request, as if it was on the page.
        This can cause a problem with session-scope checkboxes.
        Once you set the checkbox to true, the control can't set it to false
        again,
        because if you uncheck the box, nothing is sent, and so the control
        stays checked.
    </p>
</blockquote>
<hr/>

<p>
    The simplest solution is to employ our old friend Preparable again.
    In the "prepare" method for SubscriptionSave,
    we can set the property represented by the checkbox to false.
    If the control is not submitted, then the property remains false.
    If the control is submitted, then the property is set to true.
</p>

<hr/>
<h5>SubscriptionSave</h5>
<pre><code>public final class SubscriptionSave extends Subscription {

    public void prepare() {
    super.prepare();
    // checkbox workaround
    <strong>getSubscription().setAutoConnect(false);</strong>
    }

    public String execute() throws Exception {
    return save();
    }
    }</code></pre>
<hr/>


<p>
    If we press the SAVE button,
    the form will be submitted to the SubscriptionSave action.
    If the validation succeeds, as we've seen,
    SubscriptionSave will invoke the Subscription.save method.
</p>

<hr/>
<h5>Subscription save method</h5>
<pre><code>public String <strong>save</strong>() throws Exception {

    if (Constants.DELETE.equals(getTask())) {
    <strong>removeSubscription</strong>();
    }

    if (Constants.CREATE.equals(getTask())) {
    <strong>copySubscription(</strong>getHost());
    }

    saveUser();
    return SUCCESS;
    }</code></pre>
<hr/>

<p>
    The <strong>save</strong> method uses the Task property to handle
    the special cases of deleting and creating,
    and then updates the state of the User object.
</p>

<p>
    The <strong>removeSubscription</strong> method calls the DAO facade,
    and then updates the application state.
</p>

<hr/>
<h5>removeSubscription</h5>
<pre><code>public void <strong>removeSubscription</strong>() throws Exception {
    getUser().removeSubscription(getSubscription());
    getSession().remove(Constants.SUBSCRIPTION_KEY);
    }</code></pre>
<hr/>

<p>
    The <strong>copySubscription</strong> method is a bit more interesting.
    The MailReader DAO layer API includes some immutable fields
    that can't be set once the object is created.
    Because key fields are immutable,
    we can't just create a Subscription, let the framework populate all the fields,
    and then save it when we are done -- because some fields can't be populated,
    except at construction.
</p>

<p>
    One workaround would be to declare properties on the Action
    for all the properties we need to pass to the Subscription or User objects.
    When we are ready to create the object,
    we could pass the new object values from the Action properties.
</p>

<p>
    Another workaround is to declare only the immutable properties on the Action,
    and then use what we can from the domain object.
</p>

<p>
    This implementation of the MailReader utilizes the second alternative.
    We define User and Subscription objects on our base Action,
    and add other properties only as needed.
</p>

<p>
    To add a new Subscription or User,
    we create a blank object to capture whatever fields we can.
    When this "input" object returns, we create a new object,
    setting the immutable fields to appropriate values,
    and copy over the rest of the properties.
</p>

<hr/>
<h5>copySubscription</h5>
<pre><code>public void <strong>copySubscription</strong>(String host) {
    Subscription input = getSubscription();
    Subscription sub = createSubscription(host);
    if (null != sub) {
    <strong>BeanUtils.setValues</strong>(sub, input, null);
    setSubscription(sub);
    setHost(sub.getHost());
    }
    }</code></pre>

<p>
    Of course, this is not a preferred solution,
    but merely a way to work around an issue in the MailReader DAO API
    that would not be easy for us change.
</p>

<h3>Summary</h3>

<p>
    At this point, we've booted the application, logged on,
    reviewed a Registration record, and edited a Subscription.
    Of course, there's more, but from here on, it is mostly more of the same.
    The full source code for MailReader is
    <a href="http://svn.apache.org/viewcvs.cgi/struts/sandbox/trunk/struts2/apps/mailreader/">available online</a>
    and in the distribution.
</p>

<p>
    Enjoy!
</p>

</body>
</html>
