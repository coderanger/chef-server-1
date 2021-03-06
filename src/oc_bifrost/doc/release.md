Cutting a New Release of Bifrost
================================

Currently, a few steps are required to cut a release of Bifrost.  We
first need to tag a release of the schema using
[sqitch](../schema/doc/sqitch_background.md).  Then we need to create
the OTP release of the application.

## Rationale

While the schema and application code are in the same repository, we
are adopting the convention that a new schema release should be tagged
with each application code release, whether there are schema changes
or not.  This makes is a bit easier to keep track of things; you know
that if you're deploying version 2.0.0 of the application server code,
you also will be deploying 2.0.0 of the schema.

This also means that whenever you have schema changes, you need a new
code release, whether or not there are code changes.

This process may change in the future.  In our initial work with
adopting sqitch, however, it seemed the most straightforward way to
proceed for the time being.

## Schema Release

Sqitch has the notion of tagging the schema changes at a given point
in time.  If you deploy version 1.0.0 of the schema, all changesets up
to the point where you tagged it at "1.0.0" will be deployed.  In
practical terms, this ammounts to adding a special entry into the
`sqitch.plan` file, which can be done using sqitch itself:

    cd schema
    sqitch tag $NEW_VERSION -n $COMMENT

Sqitch does not "know" what the next version of the schema should be,
like the [rebar_lock_deps_plugin][] does for the OTP release (see
below).  As a result, you will need to ensure that the version you tag
in sqitch is going to correspond to the one that will be generated by
the `rebar_lock_deps_plugin`.

Once you tag the schema release add the resulting changes to the Git
index, but don't commit just yet.

    git add schema/sqitch.plan

This is important; don't forget!

## Application Release

To cut a proper release, we're using the [rebar_lock_deps_plugin][].
The executive summary is this:

```
BUMP=patch make prepare_release && rebar commit-release && rebar tag-release
```

Substitute `minor` or `major` for `BUMP` as necessary.  Note that the
presence of the `USE_REBAR_LOCKED` on `master` will cause all
subsequent builds to use the locked dependencies.

(The `rebar commit-release` command will commit the changes made by
the `rebar_lock_deps_plugin` as well as the schema release that you
added to the Git index earlier.)

Now you should have a new tagged release with schema and code all
properly synchronized.

[rebar_lock_deps_plugin]:https://github.com/seth/rebar_lock_deps_plugin
