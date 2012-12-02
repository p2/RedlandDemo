Redland iOS Demo App
====================

This is a simple app that demonstrates how to use the [Redland-ObjC] iOS framework. The framework is contained as a submodule, so all you need to do is:

    git clone git://github.com/p2/RedlandDemo.git
    git submodule update --init --recursive

Then open the project file in Xcode and hit `Run`. Note that on first run, the framework downloads and compiles all the [Redland C libraries][redland]. It might seem that Xcode is stuck because no progress is being shown -- just be patient, this cross-compilation takes some time.


[Redland-ObjC]: https://github.com/p2/Redland-ObjC
[redland]: http://librdf.org
