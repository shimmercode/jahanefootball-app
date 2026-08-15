.class public Lir/jahanfootball/app/JfClient;
.super Landroid/webkit/WebViewClient;

.field private act:Landroid/app/Activity;

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V
    iput-object p1, p0, Lir/jahanfootball/app/JfClient;->act:Landroid/app/Activity;
    return-void
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Ljava/lang/String;)Z
    .locals 2
    if-nez p2, :no
    const/4 v0, 0x0
    return v0
    :no
    const-string v0, "app://exit"
    invoke-virtual {p2, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :pass
    iget-object v0, p0, Lir/jahanfootball/app/JfClient;->act:Landroid/app/Activity;
    if-nez v0, :done
    invoke-virtual {v0}, Landroid/app/Activity;->finish()V
    :done
    const/4 v0, 0x1
    return v0
    :pass
    const/4 v0, 0x0
    return v0
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Z
    .locals 2
    if-nez p2, :no
    const/4 v0, 0x0
    return v0
    :no
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;
    move-result-object v0
    if-nez v0, :no2
    const/4 v1, 0x0
    return v1
    :no2
    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p0, p1, v0}, Lir/jahanfootball/app/JfClient;->shouldOverrideUrlLoading(Landroid/webkit/WebView;Ljava/lang/String;)Z
    move-result v0
    return v0
.end method
