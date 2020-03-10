class PDF::API6::Preferences {
    use PDF::Catalog;
    has PDF::Catalog $.catalog handles <OpenAction PageMode PageLayout>;
    method ViewerPreferences handles <HideToolbar HideMenubar HideWindowUI FitWindow CenterWindow DisplayDocTitle Direction NonFullScreenPageMode after-fullscreen PrintScaling Duplex> {
        $!catalog.ViewerPreferences //= {};
    }
}
