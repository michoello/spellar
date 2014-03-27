#include <boost/algorithm/string/classification.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/join.hpp>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

// Line-to-line 'diff' implementation
// a and b are comparing strings
// f is 'force'. The bigger the more hard comparison is done.
// w is 'width'. Defines the width of border made of unchanged lines surrounding changes in beautiful output
string diff(const string& sa, const string& sb, size_t f, size_t w) 
{
	struct Res {
		int op;
		size_t i;
		size_t w;
	};

	struct Cand {
		size_t ops;
		size_t ai;
		size_t bi;
		vector<Res> diff;
		Cand(size_t a_ops, size_t a_ai, size_t a_bi, const vector<Res>& a_diff) : ops(a_ops), ai(a_ai), bi(a_bi), diff(a_diff) {}
		Cand() = default;
	};

	vector<string> a, b;
    vector<Res> diff;
	boost::split(a, sa, boost::is_any_of("\n"));
	boost::split(b, sb, boost::is_any_of("\n"));
	size_t as = a.size(), bs = b.size();

    // Part 1: Find diff
	vector<Cand> rs = {Cand(0,0,0,{})};
	do {
		std::sort(rs.begin(), rs.end(), [](const Cand& x, const Cand& y)-> bool {return x.ops < y.ops;});
		rs.resize(std::min(f, rs.size()));
        
        vector<Cand> rs1;
		for(auto& r: rs)
		{
			static auto copy_push_back = [](decltype(r.diff) diff, const Res & res) -> decltype(diff) {
				diff.push_back(res);
				return diff;
			};

			if (r.bi < bs)
				rs1.emplace_back(r.ops+1, r.ai, r.bi+1, copy_push_back(r.diff, {+1, r.bi, w}));

			if (r.ai < as)
				rs1.emplace_back(r.ops+1, r.ai+1, r.bi, copy_push_back(r.diff, {-1, r.ai, w}));

			if (r.ai < as && r.bi < bs && a[r.ai] == b[r.bi])
				rs1.emplace_back(r.ops, r.ai+1, r.bi+1, copy_push_back(r.diff, { 0, r.ai, 0}));

			if (r.ai == as-1 && r.bi == bs-1)
			{
                diff = r.diff;
                rs1.clear();
                break;
			}
		}
		rs.swap(rs1);
	}
	while(!rs.empty());

    // Part 2: Beautify.
	size_t pw = 0;
	for(auto it = diff.begin(); it != diff.end(); pw = it->w, ++it)
		if (it->op == 0 && pw > 0)
			it->w += pw - 1;
	pw = 0;
	for(auto it = diff.rbegin(); it != diff.rend(); pw = it->w, ++it)
		if (it->op == 0 && pw > 0)
			it->w += pw - 1;

    vector<string> result;
	for(const auto& x: diff)
	{
		ostringstream out;
		(x.w == 0)   ? (out << "...") :
		((x.op <= 0) ? (out << (x.op == 0 ? "  " : "- ") << (x.i + 1) << " " << a[x.i])
		             : (out << "+ "                      << (x.i + 1) << " " << b[x.i]));
		result.push_back(out.str());
	}

	result.erase(unique(result.begin(), result.end()), result.end());
	return boost::join(result, "\n");
}

int __cdecl main(int argc, char* argv[])
{
    string a = "abc\ndef\nxcz\n1\n1\n1\n1\n1\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n-\n=746\n3\nsafasf\nwerqw\nqwer\nw\n";
    string b = "abc\nxcz\n123\n1\n1\n1\n1\n1\n1\n2\n3\n4\n5\n6\n7\n8\n0\n1\n2\n3\n4\n444\n5\n6\n7\n8\n9\n0\n-\n=\n3\nsafasf\nwrqw\nqwer\nw\n";
    std::cout << "OMG: " << diff(a, b, 20, 4) << "\n";
    return 0;
}
