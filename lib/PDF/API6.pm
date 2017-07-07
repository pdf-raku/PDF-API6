use PDF::Lite;

class PDF::API6
    is PDF::Lite {

    use PDF::DAO;
    use PDF::Content::Page;

    sub nums($a, $n) {
        with $a {
            fail "expected $n elements, found {.elems}"
                unless $n == .elems;
            fail "array contains non-numeric elements"
                unless all(.list) ~~ Numeric;
        }
        True;
    }
    sub name($name) { PDF::DAO.coerce: :$name }

    subset PageRef where {!.defined || $_ ~~ UInt|PDF::Content::Page};

    method preferences(
        Bool :$hide-toolbar,
        Bool :$hide-menubar,
        Bool :$hide-windowui,
        Bool :$fit-window,
        Bool :$center-window,
        Bool :$display-title,
        Str  :$direction where 'r2l'|'l2r'|!.defined,
        Str  :$page-mode where 'fullscreen'|'thumbs'|'outlines'|'none' = 'none';
        Str  :$page-layout where 'single-page'|'one-column'|'two-column-left'|'two-column-right' = 'single-page';
        Str :$after-fullscreen where 'thumbs'|'outlines'|'none'='none',
        Str :$print-scaling where 'none'|!.defined,
        Str :$duplex where 'simplex'|'flip-long-edge'|'flip-short-edge'|!.defined,
        :%first-page (
            PageRef :$page,
            Bool    :$fit,
            Numeric :$fith,
            Bool    :$fitb,
            Numeric :$fitbh,
            Numeric :$fitv,
            Numeric :$fitbv,
            List    :$fitr where nums($_, 4),
            List    :$xyz where nums($_,3),
        ) where { .keys == 0 || .<page> }
        ) {
        my $catalog = $.Root;

        $catalog<PageMode> = name( %(
            :fullscreen<FullScreen>,
            :thumbs<UseThumbs>,
            :outline<UseOutlines>,
            :none<UseNone>,
            ){$page-mode});

        $catalog<PageLayout> = name( %(
            :single-page<SinglePage>,
            :one-column<OneColumn>,
            :two-column-left<TwoColumnLeft>,
            :two-column-right<TwoColumnRight>,
            :single-page<SinglePage>,
            ){$page-layout});

        given $catalog<ViewerPreferences> //= { } {
            .<HideToolbar> = True if $hide-toolbar;
            .<HideMenubar> = True if $hide-menubar;
            .<HideWindowUI> = True if $hide-windowui;
            .<FitWindow> = True if $fit-window;
            .<CenterWindow> = True if $center-window;
            .<DisplayDocTitle> = True if $display-title;
            .<Direction> = name(.uc) with $direction;
            .<NonFullScreenPageMode> = name( %(
                :thumbs<UseThumbs>,
                :outlines<UseOutlines>,
                :none<UseNone>,
                ){$after-fullscreen});
            .<PrintScaling> = name('None') if $print-scaling ~~ 'none';
            with $duplex -> $dpx {
                .<Duplex> = name( %(
                      :simplex<Simplex>,
                      :flip-long-edge<DuplexFlipLongEdge>,
                      :flip-short-edge<DuplexFlipShortEdge>,
                    ){$dpx});
            }
        }
        if $page {
            my $page-ref = $page ~~ Numeric
                ?? self.page($page)
                !! $page;
            my $open-action = $catalog<OpenAction> = [$page-ref];
            with $open-action {
                when $fit   { .push: name('Fit') }
                when $fith  { .push($fith) }
                when $fitb  { .push: name('FitB') }
                when $fitbh {
                    .push: name('FitBH');
                    .push: $fitbh;
                }
                when $fitv {
                    .push: name('FitV');
                    .push: $fitv;
                }
                when $fitbv {
                    .push: name('FitBV');
                    .push: $fitbv;
                }
                when $fitr {
                    .push: name('FitR');
                    for $fitr.list -> $v {
                        .push: $v;
                    }
                }
                when $xyz {
                    .push: name('XYZ');
                    for $xyz.list -> $v {
                        .push: $v;
                    }
                }
            }
        }
    }
}
