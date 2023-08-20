#| A flattened view of preferences, which are spread between the
#| catalog and catalog /ViewerPreferences.
class PDF::API6::Preferences {
    use PDF::Catalog;
    has PDF::Catalog:D $.catalog is required handles <OpenAction PageMode PageLayout>;
    method ViewerPreferences handles <HideToolbar HideMenubar HideWindowUI FitWindow CenterWindow DisplayDocTitle Direction NonFullScreenPageMode after-fullscreen PrintScaling Duplex> {
        $!catalog.ViewerPreferences //= {};
    }
}
