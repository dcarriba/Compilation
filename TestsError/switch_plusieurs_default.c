int main(){
    int i, j;
    i = 10;
    j = 5;
    switch (i)
    {
    case 1:
        switch (j)
        {
        case 1:
            break;
        
        default:
            break;
        
        default:
            j = 2;
        }

        i = 10*i;
        break;
    
    default:
        break;


    }

    return 0;
}
