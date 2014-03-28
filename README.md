INTUWeakForwarder
================

"weak" references are great to use for delegate properties since they will automatically
get nil'ed out when the delegate object goes away. Alas it turns out Apple doesn't use
real weak references in its SDK but has all delegate properties as unsafe-unretained.

This means the app will crash should the programmer forget to nil out all the delegate
properties on dealloc and that delegate is called.

So what this little NSProxy class does is store the delegate as a *real* weak reference
and forwards all method invocations to it as long as it exists. When the delegate is
dealloc'ed the real weak reference will be nil and nothing will be forwarded along.

The NSProxy instance is stored using an associated object on the delegatee so when that goes
away the proxy instance will too. So generally this should be the object you are setting
the delegate property of.

Instead of writing:

		<someinstance>.delegate = self;

you write:

		<someinstance>.delegate = [INTUWeakForwarder forwardTo:self associatedWith:<someinstance>];

E.g.:

		UIScrollView *scrollView = ...;
		scrollView.delegate = [INTUWeakForwarder forwardTo:self associatedWith:scrollView];
