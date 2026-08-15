.class public Lir/jahanfootball/app/MainActivity;
.super Landroid/app/Activity;

.field private webView:Landroid/webkit/WebView;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 3
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lir/jahanfootball/app/MainActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1

    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccessFromFileURLs(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowUniversalAccessFromFileURLs(Z)V
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setMixedContentMode(I)V

    new-instance v2, Lir/jahanfootball/app/JfClient;
    invoke-direct {v2, p0}, Lir/jahanfootball/app/JfClient;-><init>(Landroid/app/Activity;)V
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    const-string v2, "file:///android_asset/index.html"
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Lir/jahanfootball/app/MainActivity;->setContentView(Landroid/view/View;)V
    return-void
.end method

.method public onBackPressed()V
    .locals 3
    iget-object v0, p0, Lir/jahanfootball/app/MainActivity;->webView:Landroid/webkit/WebView;
    if-nez v0, :super
    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z
    move-result v1
    if-eqz v1, :ask
    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V
    return-void
    :ask
    const-string v1, "window.jfAskExit&&window.jfAskExit()"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void
    :super
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method
