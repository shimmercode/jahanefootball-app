.class public Lir/jahanfootball/app/JfBack;
.super Ljava/lang/Object;
.implements Landroid/window/OnBackInvokedCallback;

.field private act:Lir/jahanfootball/app/MainActivity;

.method public constructor <init>(Lir/jahanfootball/app/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lir/jahanfootball/app/JfBack;->act:Lir/jahanfootball/app/MainActivity;
    return-void
.end method

.method public onBackInvoked()V
    .locals 1
    iget-object v0, p0, Lir/jahanfootball/app/JfBack;->act:Lir/jahanfootball/app/MainActivity;
    if-nez v0, :done
    invoke-virtual {v0}, Lir/jahanfootball/app/MainActivity;->handleBack()V
    :done
    return-void
.end method
