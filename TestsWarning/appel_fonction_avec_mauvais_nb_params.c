int f(int a, int b){
    return 0;
}

void g(int a){

}

int h(){
    return 0;
}

int main(){
    int x;
    x = f(1);
    g(x, 2);
    g();
    x = h(1, 2, 3, 4);
    return 0;
}
