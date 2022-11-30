#include <bits/stdc++.h>
#define boost ios_base::sync_with_stdio(0); cin.tie(0); cout.tie(0);
#define loop(a,b,c) for(int a = b; a <= c; a++)
#define file freopen("???.inp","r",stdin); freopen("???.out","w",stdout);
#define ll long long
using namespace std;

void solve() {
	char c;
	long double l, r;
	while(cin >> l >> c >> r) {
		if (l == 0 && r == 00) return;
		l = (ll)l%12 * 30;
		l += (long double)r/60 * 30;
		r = (ll)r%60 * 6;
		cout << setprecision(3) << fixed;
		long double res = abs(l - r);
		res = min(res, 360 - res);
		cout << res << '\n';
	}	
}
int main() { 
	boost; 
	solve();
}
