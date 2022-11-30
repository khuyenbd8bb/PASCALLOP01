// * ----------------- * //
#include <bits/stdc++.h>
#define boost ios_base::sync_with_stdio(0); cin.tie(0); cout.tie(0);
#define loop(a,b,c) for(int a = b; a <= c; a++)
#define file freopen("???.inp","r",stdin); freopen("???.out","w",stdout);
#define ll long long
using namespace std;
void solve() {
	char c; // Kí Tự Trống
	long double l, r; // l = Giờ và r = Phút ( left, right )
	while(cin >> l >> c >> r) {
		if (l == 0 && r == 00) return; // Trường Hợp BREAK
		// *** **** *** ** ** ** 
		l = (ll)l%12 * 30;
		l += (long double)r/60 * 30; // Độ của kim giờ so với 12h đúng
		r = (ll)r%60 * 6; // Độ của kim Phút so với 12h đúng
		// *** ** ** ** ** ** **  *
		cout << setprecision(3) << fixed; // set kết quả 3 chữ số thập phân
		long double res = abs(l - r); 
		res = min(res, 360 - res); // trường hợp đảm bảo yêu cầu <= 180*
		cout << res << '\n';
	}	 
}
int main() { 
	boost; 
	solve();
}
