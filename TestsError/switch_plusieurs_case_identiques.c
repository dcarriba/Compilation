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
        
        case 2:
            break;
        
        case 1:
            break;

        }
        i = 10*i;
        break;
    
    case 2:
        break;

    default:
        break;

    }

    return 0;
}
