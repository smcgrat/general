/*
* 
* Sometimes you need to over allocate the memory available to you.
* This does so splendidly. I just hope you have limits set to kill it!
* 
*/

int main()
{
        while(1)
        {
                void *m = malloc(1024*1024);
                memset(m,0,1024*1024);
        }
        return 0;
}
